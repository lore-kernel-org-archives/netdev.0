From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] missing s/dev->priv/netdev_priv(dev) in drivers/net/pcmcia/
Date: Wed, 24 Mar 2004 17:25:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40620ADD.90307@pobox.com>
References: <200403242315.53770.daniel.ritz@gmx.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: daniel.ritz@gmx.ch
In-Reply-To: <200403242315.53770.daniel.ritz@gmx.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniel Ritz wrote:
> clean up the last two instances of dev->priv in drivers/net/pcmcia.
> against 2.6.5-rc2-bk.
> 
> --- 1.27/drivers/net/pcmcia/3c589_cs.c	Wed Mar  3 01:03:51 2004
> +++ edited/drivers/net/pcmcia/3c589_cs.c	Wed Mar 24 22:29:35 2004
> @@ -716,7 +716,7 @@
>  	  "status %4.4x.\n", dev->name, (long)skb->len,
>  	  inw(ioaddr + EL3_STATUS));
>  
> -    ((struct el3_private *)dev->priv)->stats.tx_bytes += skb->len;
> +    ((struct el3_private *)netdev_priv(dev))->stats.tx_bytes += skb->len;
>  
>      /* Put out the doubleword header... */
>      outw(skb->len, ioaddr + TX_FIFO);
> --- 1.24/drivers/net/pcmcia/ibmtr_cs.c	Wed Mar  3 01:06:03 2004
> +++ edited/drivers/net/pcmcia/ibmtr_cs.c	Wed Mar 24 22:29:51 2004
> @@ -444,7 +444,7 @@
>          link->state &= ~DEV_PRESENT;
>          if (link->state & DEV_CONFIG) {
>  	    /* set flag to bypass normal interrupt code */
> -	    ((struct tok_info *)dev->priv)->sram_virt |= 1;
> +	    ((struct tok_info *)netdev_priv(dev))->sram_virt |= 1;
>  	    netif_device_detach(dev);
>  	    ibmtr_release(link);


although the patch is OK, the code itself is a bit yucky.

Can you please create a temporary variable, of struct el3_private or 
tok_info type, and eliminate that cast?

struct el3_private *priv = netdev_priv(dev);
priv->stats.tx_bytes += skb->len;

Much nicer :)

	Jeff
