From: Tom Herbert <tom@herbertland.com>
Subject: Re: How to do TCP tx checksums
Date: Mon, 16 Nov 2015 21:02:13 -0800
Message-ID: <CALx6S37AZz6UZctRxY9DOO+-x6MQ2gB9FQ2wSt8frEnegyh82Q@mail.gmail.com>
References: <564A72D3.1050407@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34788 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbKQFCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 00:02:14 -0500
Received: by ioir85 with SMTP id r85so7746231ioi.1
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 21:02:14 -0800 (PST)
In-Reply-To: <564A72D3.1050407@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2015 at 4:20 PM, Ben Greear <greearb@candelatech.com> wrote:
> Hello!
>
> I'm hacking on (my already hacked) pktgen, trying to get it to send TCP
> frames.
>
> And, having issues getting checksums to work properly.
>
> I'm trying this:
>         struct iphdr *iph = ip_hdr(skb);
>         struct net_device *odev = pkt_dev->odev;
>
>         if (pkt_dev->flags & F_TCP) {
>                 if (odev->features & NETIF_F_V4_CSUM) {
>                         skb->ip_summed = CHECKSUM_PARTIAL;
>                 } else {
>                         skb->ip_summed = CHECKSUM_NONE;
>                 }
>                 skb->csum = 0;
>                 __tcp_v4_send_check(skb, iph->saddr, iph->daddr);
>
> I added an export so I could call that __tcp_v4_send_check method
> w/out having to put a fake socket struct on the stack.
>
> But, the receiving NIC reports 100% checksum failure, so obviously
> I'm not doing it correct.
>
> Any suggestions on what I might be doing wrong or the proper method(s)
> to call?
>
It's really hard to tell what is happening without seeing the full
patch your using. Maybe you're not setting the TCP correctly or
transport header is not set right in skb.

Tom

> Thanks,
> Ben
>
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
