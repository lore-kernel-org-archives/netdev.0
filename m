From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] net: Use kmemdup rather than duplicating its
 implementation
Date: Fri, 18 Nov 2011 09:32:57 -0800
Message-ID: <20111118093257.000059eb@unknown>
References: <1321569820.1624.307.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "samuel@sortiz.org" <samuel@sortiz.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321569820.1624.307.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Nov 2011 14:43:40 -0800
Thomas Meyer <thomas@m3y3r.de> wrote:

> The semantic patch that makes this change is available
> in scripts/coccinelle/api/memdup.cocci.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
> ---
> 
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

this ^^^ comment should be removed also.

> -	memcpy(new, orig, sizeof(struct tsap_cb));
>  	spin_lock_init(&new->lock);
>  
>  	/* We don't need the old instance any more */
