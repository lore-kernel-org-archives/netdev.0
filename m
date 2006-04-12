From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] atm: clip causes unregister hang
Date: Thu, 13 Apr 2006 06:00:15 +1000
Message-ID: <20060412200015.GA19878@gondor.apana.org.au>
References: <20060412105545.3b089dd8@localhost.localdomain> <E1FTjlM-00050V-00@gondolin.me.apana.org.au> <20060412124533.14e0c4ff@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:14351 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932194AbWDLUAi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 16:00:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060412124533.14e0c4ff@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen:

On Wed, Apr 12, 2006 at 12:45:33PM -0700, Stephen Hemminger wrote:
>
>  	/* ignore non-CLIP devices */
> -	if (((struct net_device *) dev)->type != ARPHRD_ATM ||
> -	    ((struct net_device *) dev)->hard_start_xmit != clip_start_xmit)
> +	if (dev->type != ARPHRD_ATM || dev->hard_start_xmit != clip_start_xmit)
>  		return NOTIFY_DONE;

I think we need to check whether atm_init_atmarp has been done before
passing this point.  We also need to make sure that it doesn't get pulled
out from under us while we're doing this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
