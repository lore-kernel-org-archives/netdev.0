From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 1/2] pktgen: check for link down
Date: Sun, 20 Sep 2009 17:26:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909201725070.25015@ask.diku.dk>
References: <20090919221844.114e2e23@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@herjulf.net>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:36828 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752364AbZITP04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2009 11:26:56 -0400
In-Reply-To: <20090919221844.114e2e23@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for fixing this.

Acked-by: Jesper Dangaard Brouer <hawk@comx.dk>


On Sat, 19 Sep 2009, Stephen Hemminger wrote:

> If cable is pulled, pktgen shouldn't continue slamming packets into the
> device.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> --- a/net/core/pktgen.c	2009-09-19 11:20:55.546463176 -0700
> +++ b/net/core/pktgen.c	2009-09-19 11:22:44.810509240 -0700
> @@ -1959,7 +1959,7 @@ static int pktgen_setup_dev(struct pktge
> 	if (odev->type != ARPHRD_ETHER) {
> 		printk(KERN_ERR "pktgen: not an ethernet device: \"%s\"\n", ifname);
> 		err = -EINVAL;
> -	} else if (!netif_running(odev)) {
> +	} else if (!netif_running(odev) || !netif_carrier_ok(odev)) {
> 		printk(KERN_ERR "pktgen: device is down: \"%s\"\n", ifname);
> 		err = -ENETDOWN;
> 	} else {
> @@ -3410,7 +3410,7 @@ static void pktgen_xmit(struct pktgen_de
> 	/* Did we saturate the queue already? */
> 	if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)) {
> 		/* If device is down, then all queues are permnantly frozen */
> -		if (netif_running(odev))
> +		if (netif_running(odev) && netif_carrier_ok(odev))
> 			idle(pkt_dev);
> 		else
> 			pktgen_stop_device(pkt_dev);

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
