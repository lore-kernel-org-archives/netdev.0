From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] tc35815: Remove a wrong netif_wake_queue() call which
 triggers BUG_ON
Date: Sat, 20 Feb 2010 00:31:22 +0900 (JST)
Message-ID: <20100220.003122.26280041.anemo@mba.ocn.ne.jp>
References: <1266592438-10772-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ralf.roesch@rw-gmbh.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mv-drv-hcb004.ocn.ad.jp ([118.23.109.134]:42954 "EHLO
	mv-drv-hcb004.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973Ab0BSPb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 10:31:29 -0500
In-Reply-To: <1266592438-10772-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Feb 2010 00:13:58 +0900, Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> @@ -1437,7 +1437,6 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
>  		/* Transmit complete. */
>  		lp->lstats.tx_ints++;
>  		tc35815_txdone(dev);
> -		netif_wake_queue(dev);
>  		if (ret < 0)
>  			ret = 0;
>  	}

BTY, it looks isa-skelton.c have same problem.

void net_tx(struct net_device *dev)
{
...
	if (netif_queue_stopped(dev) && ! tx_full(dev))
		netif_wake_queue(dev);
...
}

static irqreturn_t net_interrupt(int irq, void *dev_id)
{
...
	if (status & TX_INTR) {
		/* Transmit complete. */
		net_tx(dev);
		np->stats.tx_packets++;
		netif_wake_queue(dev);
	}
...
}


I suppose here is the far origin of the bug :)

---
Atsushi Nemoto
