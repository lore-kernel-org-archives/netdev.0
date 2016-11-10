From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 2/7] vxlan: simplify exception handling
Date: Thu, 10 Nov 2016 10:10:09 -0800
Message-ID: <CAOrHB_BdYpCpjrzHmNmEkvhXk7u6Gb_1aRyggeCrsL0Jx1nkvw@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-3-git-send-email-pshelar@ovn.org> <20161109171018.69d08ff9@griffin>
 <CAOrHB_AkVXDOaFKy_-ccRc--=wXG14TLfoC6Vc4HSBgjbDm3sA@mail.gmail.com> <20161110104703.7386ab29@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:47148 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753655AbcKJSKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 13:10:19 -0500
Received: from mfilter5-d.gandi.net (mfilter5-d.gandi.net [217.70.178.132])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id B6A161720B2
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 19:10:12 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter5-d.gandi.net (mfilter5-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id fzyUuqQd0QQv for <netdev@vger.kernel.org>;
        Thu, 10 Nov 2016 19:10:11 +0100 (CET)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 5ADDE1720BF
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 19:10:11 +0100 (CET)
Received: by mail-it0-f41.google.com with SMTP id u205so59024872itc.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 10:10:11 -0800 (PST)
In-Reply-To: <20161110104703.7386ab29@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 1:47 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 9 Nov 2016 19:33:24 -0800, Pravin Shelar wrote:
>> I have moved the dst error handling to vxlan_build_skb(), which is
>> releasing the dst entry.
>
> Hmm, right, I missed that. But it's weird. The previous logic was
> confusing (skb is freed in case of error but not otherwise), I'm with
> you on this change. But having the same confusing logic with dst_entry
> instead doesn't improve things.
>
> Could we free both skb and dst_entry from the caller?
>

I wanted to do same, that is free dst and skb in caller function. But
that would need more changes due to discrepancy in IPv4 udp-tunnel and
IPv6 udp-tunnel api. IPv4 works on route entry and IPv6 needs dst
entry. so If caller frees dst-entry then I need additional variable to
keep track of dst entry which is what I am trying to avoid.
