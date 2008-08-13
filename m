From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 20:42:38 +1000
Message-ID: <20080813104238.GA11374@gondor.apana.org.au>
References: <20080813061317.GA4251@ff.dom.local> <20080812.231633.193696650.davem@davemloft.net> <20080813065302.GB4251@ff.dom.local> <20080813.022549.203848195.davem@davemloft.net> <20080813102701.GD5367@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56282 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753064AbYHMKm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 06:42:56 -0400
Content-Disposition: inline
In-Reply-To: <20080813102701.GD5367@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 10:27:01AM +0000, Jarek Poplawski wrote:
> 
> - in net_tx_action() we can hit a place just after clear_bit() where
> none of these bits is set. Of course, hitting this 2 times in a row
> seems to be very unprobable, yet possible, and a lock isn't helpful
> here, so probably some change around this would make this nicer.
>
> - isn't there possible some longer ping-pong between qdic_run() and
> net_tx_action() when dev_requeue_skb() would get it back to
> __netif_schedule() and so on (with NETDEV_TX_BUSY)?

Good point.  I think we should add an aliveness check in both
net_tx_action and qdisc_run.  In fact the net_tx_action problem
existed previously as well.  But it is pretty darn unlikely.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
