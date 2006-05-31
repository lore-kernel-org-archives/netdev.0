From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 22:40:36 +1000
Message-ID: <20060531124036.GA12171@gondor.apana.org.au>
References: <20060531051451.GA7110@gondor.apana.org.au> <20060530.232626.00456312.davem@davemloft.net> <20060531063152.GA8032@gondor.apana.org.au> <20060531.000818.78646242.davem@davemloft.net> <20060531120626.GA11925@gondor.apana.org.au> <1149078972.5462.72.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, mchan@broadcom.com,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4365 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964986AbWEaMlD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 08:41:03 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1149078972.5462.72.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2006 at 08:36:12AM -0400, jamal wrote:
>
> > The IRQ handler would look like
> > 
> > 	if (!spin_trylock(&dev->xmit_lock)) {
> > 		tasklet_schedule(&priv->tx_completion_tasklet);
> > 		return;
> > 	}
> > 
> > 	handle_tx_completion();
> > 	spin_unlock(&dev->xmit_lock);
> > 
> > Where the TX completion tasklet would simply do
> > 
> > 	spin_lock(&dev->xmit_lock);
> > 	handle_tx_completion();
> > 	spin_unlock(&dev->xmit_lock);
> > 
> > What do you think?
> 
> Been done in the past, bad numbers especially in SMP for reasons of
> latency and likelihood that a tasklet will run in a totally different
> CPU.

Was the bad latency measured with code like the above or was it with
an unconditional tasklet schedule?

Please note that my code will do the completion in the IRQ handler
most of the time.  Only if there is contention for the spin lock will
it defer work to the softirq.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
