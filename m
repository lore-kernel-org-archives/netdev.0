From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2]: pkt_sched: Convert CBQ to tasklet_hrtimer.
Date: Fri, 28 Aug 2009 12:30:35 -0700 (PDT)
Message-ID: <20090828.123035.192913179.davem@davemloft.net>
References: <20090821.170333.153413841.davem@davemloft.net>
	<4A97FDCD.10208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49192
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752343AbZH1TaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 15:30:22 -0400
In-Reply-To: <4A97FDCD.10208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Aug 2009 17:54:53 +0200

> I now have these dmesg warnings when playing with cbq
> 
> # tc qdisc del dev eth3 root
> # tc qdisc add dev eth3 root handle 1: est 1sec 8sec cbq avpkt 1000 rate 1000Mbit bandwidth 1000Mbit
> # tc qdisc del dev eth3 root
> 
> [12786.458485] Attempt to kill tasklet from interrupt
> [12786.458522] Attempt to kill tasklet from interrupt
> [12786.465261] Attempt to kill tasklet from interrupt
> [12786.465286] Attempt to kill tasklet from interrupt
> 
> probably becauce cbq_reset() being called from interrupt context ?

Grumble... I guess the tasklet_hrtimer infrastructure is less
of a direct plugin replacement for plain hrtimers than I thought.

Anyone have any ideas about how to deal with stuff like this?
