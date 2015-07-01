From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with
 NET_IP_ALIGN
Date: Wed, 01 Jul 2015 17:33:54 +0200
Message-ID: <1435764834.4110.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5592D105.7080006@certsign.ro>
	 <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5593EB38.5050000@certsign.ro>
	 <1435758289.4110.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5593F956.4020300@certsign.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: Nicolae Rosia <nicolae.rosia@certsign.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37221 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493AbbGAPd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 11:33:59 -0400
Received: by wicgi11 with SMTP id gi11so49155218wic.0
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 08:33:58 -0700 (PDT)
In-Reply-To: <5593F956.4020300@certsign.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-01 at 17:29 +0300, Nicolae Rosia wrote:
> On 07/01/2015 04:44 PM, Eric Dumazet wrote:
> > I really doubt this adapter can process millions of packets per second ?
> I was suggesting this since I was taking into consideration the comment 
> from skbuff.c, "we can save several CPU cycles by avoiding having to 
> disable and re-enable IRQs."
> Is there a downside to this?

This only matters in terms of few nano seconds per packet, so for 10Gb+
NIC anyway. Absolute noise for most NIC.

> 
> >
> > I would rather enable GRO, it would be more useful.
> I had no idea what GRO is, so I have read about it [0] and looked at a 
> couple of drivers which use it. They all seem to
> replace netif_receive_skb with napi_gro_receive and when there are no 
> more packets in napi_pool they call napi_gro_flush.
> Is it that simple?

Yes, but main question is : Do you have the hardware to test your
changes ?
