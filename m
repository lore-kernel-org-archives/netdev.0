From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 4 Aug 2006 11:10:27 +1000
Message-ID: <20060804011027.GC12085@gondor.apana.org.au>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au> <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com> <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2> <1154650197.3117.32.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39433 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751413AbWHDBKq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 21:10:46 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1154650197.3117.32.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 05:09:57PM -0700, Michael Chan wrote:
> 
> tg3_start_xmit()
> 
> 	if (tx_ring_empty)
> 				<-  tg3_tx()
> 		netif_stop_queue()

Good point.  I missed that.  However, this only goes to show that
even the current code (e1000 that is, I haven't checked tg3) is
also unsafe.

Why? Because the tx_lock is only taken in e1000_clean_tx_irq if
the queue is stopped.  As you can see in your diagram above, the
queue could well be awake at the point where e1000_clean_tx_irq
runs.

So we need to fix e1000 anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
