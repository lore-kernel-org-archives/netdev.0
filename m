From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable() for
 length check.
Date: Sun, 4 Dec 2016 16:22:40 -0800
Message-ID: <CAOrHB_BTRP69VDeA2_cSf_qKh05Wj=OinaqU3Uu=52Wus6xS8w@mail.gmail.com>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
 <1480462253-114713-2-git-send-email-jarno@ovn.org> <20161130145159.3cee7ba4@griffin>
 <CAOrHB_BEQBbvDa2W0dJmmANsjZEiwx7GbTxo-7yirDB=5d9cqQ@mail.gmail.com> <20161202102509.065df1e8@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:34418 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcLEAWp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 19:22:45 -0500
Received: from mfilter11-d.gandi.net (mfilter11-d.gandi.net [217.70.178.131])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 03337C5A49
        for <netdev@vger.kernel.org>; Mon,  5 Dec 2016 01:22:44 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter11-d.gandi.net (mfilter11-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 3sI-NaW662ZL for <netdev@vger.kernel.org>;
        Mon,  5 Dec 2016 01:22:42 +0100 (CET)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 23BA9C5A44
        for <netdev@vger.kernel.org>; Mon,  5 Dec 2016 01:22:42 +0100 (CET)
Received: by mail-io0-f171.google.com with SMTP id m5so433254696ioe.3
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 16:22:41 -0800 (PST)
In-Reply-To: <20161202102509.065df1e8@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 2, 2016 at 1:25 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Thu, 1 Dec 2016 11:50:00 -0800, Pravin Shelar wrote:
>> This is not changing any behavior compared to current OVS vlan checks.
>> Single vlan header is not considered for MTU check.
>
> It is changing it.
>
> Consider the case when there's an interface with MTU 1500 forwarding to
> an interface with MTU 1496. Obviously, full-sized vlan frames
> ingressing on the first interface are not forwardable to the second
> one. Yet, if the vlan tag is accelerated (and thus not counted in
> skb->len), is_skb_forwardable happily returns true because of the check
>
>         len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
>         if (skb->len <= len)
>
ok, This case would be allowed due to this patch. But core linux stack
and bridge is using this check then why not just use same forwarding
check in OVS too, this make it consistent with core networking
forwarding expectations.
