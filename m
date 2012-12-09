From: Eric Dumazet <edumazet@google.com>
Subject: Re: ipgre rss is broken since gro
Date: Sun, 9 Dec 2012 15:27:07 -0800
Message-ID: <CANn89iKtWuN=CRn-JBzmmo8jCCJQhZjAT8jA+9dgfmup99O03g@mail.gmail.com>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
	<504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
	<CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
	<1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
	<1355086161.3113.9.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:51559 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab2LIX1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 18:27:08 -0500
Received: by mail-ie0-f176.google.com with SMTP id 13so6817154iea.35
        for <netdev@vger.kernel.org>; Sun, 09 Dec 2012 15:27:07 -0800 (PST)
In-Reply-To: <1355086161.3113.9.camel@lb-tlvb-dmitry.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 9, 2012 at 12:49 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:

> for this item: drop_watch does not show any drops (i've disable all
> other interfaces for clear env)
> I will explain a little bit more the setup:
> bnx2x device (under testing) is configured for RSS for IPGRE packets.
> Sending multiple (3) TCP_STREAM causes ip_gre interface to disappear
> packets (even ICMP).
> This is not happening with single TCP_STREAM, or before gro_cell
> introduction.
>
> i was searching for the drops by print-out in ip_gre.c but disappeared
> packets completes this code:
>
> static int ipgre_rcv(struct sk_buff *skb)
> (snip)
>                 printk("%s:%d\n", __FUNCTION__, __LINE__);
>
>                 tstats = this_cpu_ptr(tunnel->dev->tstats);
>                 u64_stats_update_begin(&tstats->syncp);
>                 tstats->rx_packets++;
>                 tstats->rx_bytes += skb->len;
>                 u64_stats_update_end(&tstats->syncp);
>
>                 gro_cells_receive(&tunnel->gro_cells, skb);
>                 return 0;

I dont know, I tried a bnx2x setup, and 100 tcp flows, no special problem.

If you receive a lot of packets on a single RX queue, they might be
dropped because cpu cant cope with the load
(This has nothing to do with GRE or GRO )

cat /proc/net/softnet_stat
