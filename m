From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Use kmemdup rather than duplicating its
 implementation
Date: Fri, 18 Nov 2011 15:48:18 +0000
Message-ID: <1321631298.2885.119.camel@deadeye>
References: <1321569820.1624.307.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <samuel@sortiz.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321569820.1624.307.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-11-17 at 23:43 +0100, Thomas Meyer wrote:
> The semantic patch that makes this change is available
> in scripts/coccinelle/api/memdup.cocci.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
> ---

Similarly this is for the specific driver 'irttp' and not generally
'net'.

Ben.

> diff -u -p a/net/irda/irttp.c b/net/irda/irttp.c
> --- a/net/irda/irttp.c 2011-11-07 19:39:06.071138486 +0100
> +++ b/net/irda/irttp.c 2011-11-08 10:59:07.152748948 +0100
> @@ -1461,14 +1461,13 @@ struct tsap_cb *irttp_dup(struct tsap_cb
>  	}
>  
>  	/* Allocate a new instance */
> -	new = kmalloc(sizeof(struct tsap_cb), GFP_ATOMIC);
> +	new = kmemdup(orig, sizeof(struct tsap_cb), GFP_ATOMIC);
>  	if (!new) {
>  		IRDA_DEBUG(0, "%s(), unable to kmalloc\n", __func__);
>  		spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
>  		return NULL;
>  	}
>  	/* Dup */
> -	memcpy(new, orig, sizeof(struct tsap_cb));
>  	spin_lock_init(&new->lock);
>  
>  	/* We don't need the old instance any more */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
