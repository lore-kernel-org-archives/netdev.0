From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] openvswitch: avoid deferred execution of recirc actions
Date: Tue, 13 Sep 2016 13:52:32 -0700
Message-ID: <CAOrHB_DE-iTQQawmbthXwngMar5Pm+RVE6PED_trkMXv3P2t2Q@mail.gmail.com>
References: <1473775734-27382-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>, sramamur@linux.vnet.ibm.com
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:46542 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbcIMUwh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 16:52:37 -0400
Received: from mfilter10-d.gandi.net (mfilter10-d.gandi.net [217.70.178.139])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id C08ADA861A
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 22:52:35 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter10-d.gandi.net (mfilter10-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id nP3ScvlfyQcH for <netdev@vger.kernel.org>;
        Tue, 13 Sep 2016 22:52:34 +0200 (CEST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 1B051A841C
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 22:52:33 +0200 (CEST)
Received: by mail-it0-f53.google.com with SMTP id o3so15045291ita.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 13:52:33 -0700 (PDT)
In-Reply-To: <1473775734-27382-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2016 at 7:08 AM, Lance Richardson <lrichard@redhat.com> wrote:
> The ovs kernel data path currently defers the execution of all
> recirc actions until stack utilization is at a minimum.
> This is too limiting for some packet forwarding scenarios due to
> the small size of the deferred action FIFO (10 entries). For
> example, broadcast traffic sent out more than 10 ports with
> recirculation results in packet drops when the deferred action
> FIFO becomes full, as reported here:
>
>      http://openvswitch.org/pipermail/dev/2016-March/067672.html
>
> Since the current recursion depth is available (it is already tracked
> by the exec_actions_level pcpu variable), we can use it to determine
> whether to execute recirculation actions immediately (safe when
> recursion depth is low) or defer execution until more stack space is
> available.
>
> With this change, the deferred action fifo size becomes a non-issue
> for currently failing scenarios because it is no longer used when
> there are three or fewer recursions through ovs_execute_actions().
>
> Suggested-by: Pravin Shelar <pshelar@ovn.org>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Thanks for working on it.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
