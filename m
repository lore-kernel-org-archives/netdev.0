From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/5] sis900 printk and stack usage audit
Date: Sat, 11 Dec 2004 14:11:13 -0500
Message-ID: <41BB4651.4040106@pobox.com>
References: <20041208104721.GA31707@picchio.gall.it> <20041208110835.GE31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
In-Reply-To: <20041208110835.GE31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano wrote:
> @@ -952,7 +952,11 @@
>  	sis900_reset(net_dev);
>  
>  	/* Equalizer workaround Rule */
> -	sis630_set_eq(net_dev, sis_priv->chipset_rev);
> +	if (sis_priv->chipset_rev == SIS630E_900_REV ||
> +			sis_priv->chipset_rev == SIS630EA1_900_REV ||
> +			sis_priv->chipset_rev == SIS630A_900_REV ||
> +			sis_priv->chipset_rev ==  SIS630ET_900_REV)
> +		sis630_set_eq(net_dev);
>  
>  	ret = request_irq(net_dev->irq, &sis900_interrupt, SA_SHIRQ,
>  						net_dev->name, net_dev);
> @@ -1141,16 +1145,12 @@
>   *	max >= 15      --> set equalizer to max+5 or set equalizer to max+6 if max == min
>   */
>  
> -static void sis630_set_eq(struct net_device *net_dev, u8 revision)
> +static void sis630_set_eq(struct net_device *net_dev)
>  {
>  	struct sis900_private *sis_priv = net_dev->priv;
>  	u16 reg14h, eq_value=0, max_value=0, min_value=0;
>  	int i, maxcount=10;
>  
> -	if ( !(revision == SIS630E_900_REV || revision == SIS630EA1_900_REV ||
> -	       revision == SIS630A_900_REV || revision ==  SIS630ET_900_REV) )
> -		return;
> -
>  	if (netif_carrier_ok(net_dev)) {
>  		reg14h = mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
>  		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,


This is a step backwards.

You are _adding_ multiple copies of the same piece of code, just to 
avoid calling a function.

	Jeff
