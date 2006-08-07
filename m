From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 8 Aug 2006 09:23:40 +1000
Message-ID: <20060807232340.GA11088@gondor.apana.org.au>
References: <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com> <1154955036.5246.32.camel@jzny2> <20060807152126.GL24653@edgar.underground.se.axis.com> <1154965249.5446.15.camel@jzny2> <20060807155929.GM24653@edgar.underground.se.axis.com> <1154968319.5446.30.camel@jzny2> <20060807170403.GA10818@edgar.underground.se.axis.com> <1154973625.5446.56.camel@jzny2> <20060807184748.GA10909@edgar.underground.se.axis.com> <1154977413.5446.83.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50181 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932291AbWHGXZB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:25:01 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154977413.5446.83.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 03:03:33PM -0400, jamal wrote:
> 
> -#define E1000_TX_WEIGHT 64
> -               /* weight of a sort for tx, to avoid endless transmit
> cleanup */
> -               if (count++ == E1000_TX_WEIGHT) break;
> +               /* avoid endless transmit cleanup */
> +               if (count++ == tx_ring->prunet) break;
> 
> As you can see E1000_TX_WEIGHT threshold exists today and you are right
> if no TX interupts, packet arrivals or scheduled wakes happen the that
> descriptor that was not pruned will sit there forever (which is a bad
> thing for TCP). Are we in sync?
> If yes, what is the likelihood they will sit there forever? I think
> perhaps some TX interupts will happen, no?

I thought this code is only used for NAPI so as long as work was done
it'll keep calling this.

One thing I'm not sure about though is the time between it decides that
there is no work and the point where the interrupts are reenabled.

What if work arrives in that time and no work ever arrives after the
interrupts are turned on again? Does that mean the work will sit there
forever?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
