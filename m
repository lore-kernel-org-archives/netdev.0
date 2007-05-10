From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 22:10:10 +1000
Message-ID: <20070510121010.GA25264@gondor.apana.org.au>
References: <1178725965.4058.75.camel@localhost> <OFF9085DDC.F5960247-ON652572D7.001B794E-652572D7.001CA7E2@in.ibm.com> <20070510115039.GA24439@gondor.apana.org.au> <20070510.045534.90119358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2847 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752490AbXEJMK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 08:10:27 -0400
Content-Disposition: inline
In-Reply-To: <20070510.045534.90119358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 04:55:34AM -0700, David Miller wrote:
>
> > [NET_SCHED]: Rationalise return value of qdisc_restart
> 
> Fair enough, patch applied :-)

Sorry, reading Thomas's patch made me realise that I've just added
that bug all over again.

[NET_SCHED]: Reread dev->qdisc for NETDEV_TX_OK

Now that we return the queue length after NETDEV_TX_OK we better
make sure that we have the right queue.  Otherwise we can cause a
stall after a really quick dev_deactive/dev_activate.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Chers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 3480e81..5f04b06 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -132,6 +132,7 @@ static inline int qdisc_restart(struct net_device *dev)
 						netif_tx_unlock(dev);
 					}
 					spin_lock(&dev->queue_lock);
+					q = dev->qdisc;
 					goto out;
 				}
 				if (ret == NETDEV_TX_LOCKED && nolock) {
