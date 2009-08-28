From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2]: pkt_sched: Convert CBQ to tasklet_hrtimer.
Date: Fri, 28 Aug 2009 21:51:40 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0908282147550.19335@localhost.localdomain>
References: <20090821.170333.153413841.davem@davemloft.net> <4A97FDCD.10208@gmail.com> <20090828.123035.192913179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:42775 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbZH1Tvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2009 15:51:46 -0400
In-Reply-To: <20090828.123035.192913179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2009, David Miller wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 28 Aug 2009 17:54:53 +0200
> 
> > I now have these dmesg warnings when playing with cbq
> > 
> > # tc qdisc del dev eth3 root
> > # tc qdisc add dev eth3 root handle 1: est 1sec 8sec cbq avpkt 1000 rate 1000Mbit bandwidth 1000Mbit
> > # tc qdisc del dev eth3 root
> > 
> > [12786.458485] Attempt to kill tasklet from interrupt
> > [12786.458522] Attempt to kill tasklet from interrupt
> > [12786.465261] Attempt to kill tasklet from interrupt
> > [12786.465286] Attempt to kill tasklet from interrupt
> > 
> > probably becauce cbq_reset() being called from interrupt context ?
> 
> Grumble... I guess the tasklet_hrtimer infrastructure is less
> of a direct plugin replacement for plain hrtimers than I thought.
> 
> Anyone have any ideas about how to deal with stuff like this?

Hmm. Is it sufficient to cancel just the timer and let an eventually
scheduled tasklet deal with the cleanup ?

Thanks,

	tglx

