From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: dev_add_pack() duplicate skb ?
Date: Wed, 13 Feb 2013 07:05:25 -0800
Message-ID: <1360767925.6884.22.camel@edumazet-glaptop>
References: <CAJX4=r08yC7PPtO7KA-3rsY5SMsZueJ=tVDdi2HT6MvnuO1ung@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felipe Dias <felipediassss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:43579 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934110Ab3BMPF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 10:05:28 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so741178pad.37
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2013 07:05:28 -0800 (PST)
In-Reply-To: <CAJX4=r08yC7PPtO7KA-3rsY5SMsZueJ=tVDdi2HT6MvnuO1ung@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-13 at 10:11 -0200, Felipe Dias wrote:
> Hi, someone might try to tell me what I'm doing wrong, please?
> 
> 
> I have a simple module and I registered one packet handler, in init function:
> ---
>      pseudo_proto.type = htons(ETH_P_ALL);
>      pseudo_proto.dev = NULL;
>      pseudo_proto.func = packet_handler;
>      dev_add_pack(&pseudo_proto);
> ---
> 
> My packet_handler, is a simple function just to print in dmesg info
> about the packet:
> 
> ---
> ...
> 
>     switch (ntohs(eth_hdr(skb)->h_proto))
>     {
>         case ETH_P_IPV6:
>             printk(KERN_INFO "%s: (%s %d %s, %s %d) Packet\n",
>                        THIS_MODULE->name,
>                        skb->dev->name,
>                        skb->dev->type,
>                        ntohs(eth_hdr(skb)->h_proto,
>                        ipv6_hdr(skb)->nexthdr,
>                        skb->len);
>             break;
> ...
> ---
> 
> When I sent a icmpv6 with a ping6 -c1 ::1 , this in my tcpdump show
> only 2 packets (icmp request and icmp reply), but in my dmesg I see
> 4!:
> 
> ---
> 595:[30469.099222] test: (lo 772 0x86dd, 0x3a 118) Packet
> 596:[30469.099226] test: (lo 772 0x86dd, 0x3a 104) Packet
> 597:[30469.099234] test: (lo 772 0x86dd, 0x3a 118) Packet
> 598:[30469.099236] test: (lo 772 0x86dd, 0x3a 104) Packet
> ---
> 
> This show 4 packets in ipv4 too. What I'm doing wrong ?

The ICMP request is sent, _and_ received : 2 packets
The ICMP response is sent, _and_ received : 2 packets

Total : 4 packets.

af_packet has special code to avoid seeing packets twice on loopback, as
it would be a bit annoying.
