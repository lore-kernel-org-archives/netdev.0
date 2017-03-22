From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization v4 3/4] openvswitch:
 Optimize sample action for the clone use cases
Date: Tue, 21 Mar 2017 22:59:46 -0700
Message-ID: <CAOrHB_CG7PTUjwKqDk=WPmU4heU-=k8TrB_TTcL+_b+c8O7O-Q@mail.gmail.com>
References: <1490052750-60187-1-git-send-email-azhou@ovn.org> <1490052750-60187-4-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:40255 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758404AbdCVGAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 02:00:48 -0400
Received: from mfilter19-d.gandi.net (mfilter19-d.gandi.net [217.70.178.147])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 6E2171720A1
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 06:59:49 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter19-d.gandi.net (mfilter19-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Y7Oouh4_CvJJ for <netdev@vger.kernel.org>;
        Wed, 22 Mar 2017 06:59:48 +0100 (CET)
Received: from mail-wr0-f178.google.com (mail-wr0-f178.google.com [209.85.128.178])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 17278172097
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 06:59:47 +0100 (CET)
Received: by mail-wr0-f178.google.com with SMTP id y90so6151230wrb.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 22:59:47 -0700 (PDT)
In-Reply-To: <1490052750-60187-4-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 4:32 PM, Andy Zhou <azhou@ovn.org> wrote:
> With the introduction of open flow 'clone' action, the OVS user space
> can now translate the 'clone' action into kernel datapath 'sample'
> action, with 100% probability, to ensure that the clone semantics,
> which is that the packet seen by the clone action is the same as the
> packet seen by the action after clone, is faithfully carried out
> in the datapath.
>
> While the sample action in the datpath has the matching semantics,
> its implementation is only optimized for its original use.
> Specifically, there are two limitation: First, there is a 3 level of
> nesting restriction, enforced at the flow downloading time. This
> limit turns out to be too restrictive for the 'clone' use case.
> Second, the implementation avoid recursive call only if the sample
> action list has a single userspace action.
>
> The main optimization implemented in this series removes the static
> nesting limit check, instead, implement the run time recursion limit
> check, and recursion avoidance similar to that of the 'recirc' action.
> This optimization solve both #1 and #2 issues above.
>
> One related optimization attempts to avoid copying flow key as
> long as the actions enclosed does not change the flow key. The
> detection is performed only once at the flow downloading time.
>
> Another related optimization is to rewrite the action list
> at flow downloading time in order to save the fast path from parsing
> the sample action list in its original form repeatedly.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
