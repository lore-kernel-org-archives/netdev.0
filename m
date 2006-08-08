From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 8 Aug 2006 11:22:17 +1000
Message-ID: <20060808012217.GA12468@gondor.apana.org.au>
References: <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net> <1154797002.5081.21.camel@jzny2> <20060805230517.GA25468@gondor.apana.org.au> <1154819868.5517.34.camel@jzny2> <20060805231959.GA25768@gondor.apana.org.au> <1154821010.5517.48.camel@jzny2> <20060806025123.GA27051@gondor.apana.org.au> <1154867083.6269.35.camel@jzny2> <1154999971.5138.19.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3592 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751197AbWHHBWl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 21:22:41 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154999971.5138.19.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 09:19:31PM -0400, jamal wrote:
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d95e262..977e77e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1092,7 +1092,8 @@ static void dev_queue_xmit_nit(struct sk
>  
>  void __netif_schedule(struct net_device *dev)
>  {
> -	if (!test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {
> +	if (!test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state) &&
> +	    !test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {
>  		unsigned long flags;
>  		struct softnet_data *sd;

I'm not sure if this is safe.  What if the other side clears QDISC_RUNNING
right after you test it here? Wouldn't you miss the schedule altogether?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
