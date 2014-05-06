From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Is 3.18 patch "The tcp: TSO packets automatic sizing" will
 cause to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Tue, 06 May 2014 09:30:21 -0700
Message-ID: <1399393821.15399.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: V JobNickname <workofv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64947 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaEFQaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:30:24 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so11468433pab.39
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 09:30:23 -0700 (PDT)
In-Reply-To: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-07 at 00:17 +0800, V JobNickname wrote:
> When I porting my ARM platform to Kernel 3.10.0 the network throughput
> of TCP tx is about 160 Mbps.
> 
> After I applied patch-3.10.37, the TCP tx drop to 8x Mbps.
> I found that after I disabled CONFIG_HIGH_RES_TIMERS and NO_HZ_IDEL,
> the throughput can back to 16x Mbps.
> 
> I try to find the more step patches and tile patch-3.10.17, the
> throughput with enabled NO_HZ_IDEL or HIGH_RES_TIMERS can still have
> 16x Mbps
> After applied patch-3.10.17-18, it start to drop the performance.
> 
> More detail trace, the first commit of 3.10.18, tcp: TSO packets
> automatic sizing, cause to this issue.
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/diff/?id=5e25ba5003ee5de0ba2be56bfd54d16d4b1b028d
> 
> I don't know why this TSO patch affect my network since the network
> driver doesn't enable NETIF_F_TSO.
> But I
> (dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> dev->features |= dev->hw_features;)
> 
> After look into the commit difference,
> I can just doubt if function "tcp_update_pacing_rate" can work well
> with NO_HZ_IDEL or HIGH_RES_TIMERS, since it base on jiffie to
> calculate the rate instead of human nenosecond of new timer
> arch(clocksource/clockevent)
> --

I cant see any effect for this patch explaining a 50% reduction in
speed, unless a special qdisc setup maybe.
