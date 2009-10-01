From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] pkt_sched: gen_estimator: Dont report fake rate
 estimators
Date: Thu, 01 Oct 2009 12:37:25 -0700 (PDT)
Message-ID: <20091001.123725.02194664.davem@davemloft.net>
References: <4AC4FE07.5070204@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38503
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755546AbZJAThH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 15:37:07 -0400
In-Reply-To: <4AC4FE07.5070204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Oct 2009 21:07:51 +0200

> We currently send TCA_STATS_RATE_EST elements to netlink users, even if no estimator
> is running.
> 
> # tc -s -d qdisc
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 112833764978 bytes 1495081739 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> 
> User has no way to tell if the "rate 0bit 0pps" is a real estimation, or a fake
> one (because no estimator is active)
> 
> After this patch, tc command output is :
> $ tc -s -d qdisc
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 561075 bytes 1196 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'm generally fine with this idea.

The new behavior is certainly more intuitive even to me :-)

Unless there are other objections I'm ok with this and I'll apply
your final version when I start taking changes for net-next-2.6
(which is probably right after -rc3 is released).
