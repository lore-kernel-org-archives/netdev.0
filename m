From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH RFC 4/6] net/faraday: Replace use_nc_si with use_ncsi
Date: Mon, 09 Nov 2015 11:30:35 +1100
Message-ID: <1447029035.8727.27.camel@kernel.crashing.org>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <1447027806-4744-5-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39881 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421AbbKIAar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 19:30:47 -0500
In-Reply-To: <1447027806-4744-5-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-09 at 11:10 +1100, Gavin Shan wrote:
> This replaces variable name "use_nc_si" with "use_ncsi". No logical
> changes introduced.

This driver patch is against an internal tree, not upstream. Please
ignore. The upstream driver doesn't have any concept of "nc_si".

Gavin, next time you respin the series, make sure it's against
upstream.

Cheers,
Ben.

> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> ---
> =C2=A0drivers/net/ethernet/faraday/ftgmac100.c | 14 +++++++-------
> =C2=A01 file changed, 7 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c
> b/drivers/net/ethernet/faraday/ftgmac100.c
> index 08e0336..778bee8 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -75,7 +75,7 @@ struct ftgmac100 {
> =C2=A0	struct phy_device *phydev;
> =C2=A0	int old_speed;
> =C2=A0
> -	bool use_nc_si;
> +	bool use_ncsi;
> =C2=A0};
> =C2=A0
> =C2=A0static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
> @@ -1150,11 +1150,11 @@ static int ftgmac100_open(struct net_device
> *netdev)
> =C2=A0		goto err_hw;
> =C2=A0
> =C2=A0	ftgmac100_init_hw(priv);
> -	ftgmac100_start_hw(priv, priv->use_nc_si ? 100 : 10);
> +	ftgmac100_start_hw(priv, priv->use_ncsi ? 100 : 10);
> =C2=A0
> =C2=A0	if (priv->phydev)
> =C2=A0		phy_start(priv->phydev);
> -	else if (priv->use_nc_si)
> +	else if (priv->use_ncsi)
> =C2=A0		netif_carrier_on(priv->netdev);
> =C2=A0
> =C2=A0	napi_enable(&priv->napi);
> @@ -1275,7 +1275,7 @@ err_alloc_mdiobus:
> =C2=A0
> =C2=A0static void ftgmac100_destroy_mdio(struct ftgmac100 *priv)
> =C2=A0{
> -	if (!priv->use_nc_si)
> +	if (!priv->use_ncsi)
> =C2=A0		return;
> =C2=A0	phy_disconnect(priv->phydev);
> =C2=A0	mdiobus_unregister(priv->mii_bus);
> @@ -1359,9 +1359,9 @@ static int ftgmac100_probe(struct
> platform_device *pdev)
> =C2=A0	/* Check for NC-SI mode */
> =C2=A0	if (pdev->dev.of_node &&
> =C2=A0	=C2=A0=C2=A0=C2=A0=C2=A0of_get_property(pdev->dev.of_node, "us=
e-nc-si", NULL))
> -		priv->use_nc_si =3D true;
> +		priv->use_ncsi =3D true;
> =C2=A0	else
> -		priv->use_nc_si =3D false;
> +		priv->use_ncsi =3D false;
> =C2=A0
> =C2=A0	/* If we use NC-SI, we need to set that up, which isn't
> implemented yet
> =C2=A0	=C2=A0* so we pray things were setup by the bootloader and jus=
t
> mark our link
> @@ -1370,7 +1370,7 @@ static int ftgmac100_probe(struct
> platform_device *pdev)
> =C2=A0	=C2=A0* Eventually, we'll have a proper NC-SI stack as a helpe=
r
> we can
> =C2=A0	=C2=A0* instanciate
> =C2=A0	=C2=A0*/
> -	if (priv->use_nc_si) {
> +	if (priv->use_ncsi) {
> =C2=A0		/* XXX */
> =C2=A0		priv->phydev =3D NULL;
> =C2=A0		dev_info(&pdev->dev, "Using NC-SI interface\n");
