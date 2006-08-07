From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 13:53:14 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0608071350510.3576@jbrandeb-desk.amr.corp.intel.com>
References: <1154867083.6269.35.camel@jzny2>  <1154867589.6269.40.camel@jzny2>
  <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
 <1154955036.5246.32.camel@jzny2>  <20060807152126.GL24653@edgar.underground.se.axis.com>
  <1154965249.5446.15.camel@jzny2>  <20060807155929.GM24653@edgar.underground.se.axis.com>
  <1154968319.5446.30.camel@jzny2>  <20060807170403.GA10818@edgar.underground.se.axis.com>
  <1154973625.5446.56.camel@jzny2>  <20060807184748.GA10909@edgar.underground.se.axis.com>
 <1154977413.5446.83.camel@jzny2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46226 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S932364AbWHGU5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 16:57:36 -0400
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1154977413.5446.83.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 7 Aug 2006, jamal wrote:
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

we don't enable it right now, but you could use the TXQE (tx queue empty) 
interrupt to avoid the starvation case.  I think it might flood you with 
TXQE interrupts however, so we'd probably have to figure out some way to 
turn it on occasionally.

Jesse
