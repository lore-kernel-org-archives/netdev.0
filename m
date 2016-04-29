From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH RFT v2 2/2] macb: kill PHY reset code
Date: Fri, 29 Apr 2016 11:36:52 +0200
Message-ID: <57232B34.4060107@atmel.com>
References: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
 <2024144.Eda96jDyaz@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:51855 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbcD2Jgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 05:36:48 -0400
In-Reply-To: <2024144.Eda96jDyaz@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/04/2016 00:15, Sergei Shtylyov a =E9crit :
> With  the 'phylib' now  being aware of  the "reset-gpios" PHY node pr=
operty,
> there should be no need to frob the PHY reset in this  driver anymore=
=2E..
>=20
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

So I queue my DT patch through arm-soc.

Thanks Sergei, bye.

> ---
>  drivers/net/ethernet/cadence/macb.c |   17 -----------------
>  drivers/net/ethernet/cadence/macb.h |    1 -
>  2 files changed, 18 deletions(-)
>=20
> Index: net-next/drivers/net/ethernet/cadence/macb.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next.orig/drivers/net/ethernet/cadence/macb.c
> +++ net-next/drivers/net/ethernet/cadence/macb.c
> @@ -2884,7 +2884,6 @@ static int macb_probe(struct platform_de
>  					      =3D macb_clk_init;
>  	int (*init)(struct platform_device *) =3D macb_init;
>  	struct device_node *np =3D pdev->dev.of_node;
> -	struct device_node *phy_node;
>  	const struct macb_config *macb_config =3D NULL;
>  	struct clk *pclk, *hclk =3D NULL, *tx_clk =3D NULL;
>  	unsigned int queue_mask, num_queues;
> @@ -2977,18 +2976,6 @@ static int macb_probe(struct platform_de
>  	else
>  		macb_get_hwaddr(bp);
> =20
> -	/* Power up the PHY if there is a GPIO reset */
> -	phy_node =3D  of_get_next_available_child(np, NULL);
> -	if (phy_node) {
> -		int gpio =3D of_get_named_gpio(phy_node, "reset-gpios", 0);
> -
> -		if (gpio_is_valid(gpio)) {
> -			bp->reset_gpio =3D gpio_to_desc(gpio);
> -			gpiod_direction_output(bp->reset_gpio, 1);
> -		}
> -	}
> -	of_node_put(phy_node);
> -
>  	err =3D of_get_phy_mode(np);
>  	if (err < 0) {
>  		pdata =3D dev_get_platdata(&pdev->dev);
> @@ -3054,10 +3041,6 @@ static int macb_remove(struct platform_d
>  		mdiobus_unregister(bp->mii_bus);
>  		mdiobus_free(bp->mii_bus);
> =20
> -		/* Shutdown the PHY if there is a GPIO reset */
> -		if (bp->reset_gpio)
> -			gpiod_set_value(bp->reset_gpio, 0);
> -
>  		unregister_netdev(dev);
>  		clk_disable_unprepare(bp->tx_clk);
>  		clk_disable_unprepare(bp->hclk);
> Index: net-next/drivers/net/ethernet/cadence/macb.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net-next.orig/drivers/net/ethernet/cadence/macb.h
> +++ net-next/drivers/net/ethernet/cadence/macb.h
> @@ -832,7 +832,6 @@ struct macb {
>  	unsigned int		dma_burst_length;
> =20
>  	phy_interface_t		phy_interface;
> -	struct gpio_desc	*reset_gpio;
> =20
>  	/* AT91RM9200 transmit */
>  	struct sk_buff *skb;			/* holds skb until xmit interrupt completes =
*/
>=20
>=20


--=20
Nicolas Ferre
