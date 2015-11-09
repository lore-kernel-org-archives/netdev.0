From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 4/6] net/faraday: Replace use_nc_si with use_ncsi
Date: Mon, 9 Nov 2015 11:45:20 +1100
Message-ID: <20151109004520.GB17877@gwshan>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1447027806-4744-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <1447029035.8727.27.camel@kernel.crashing.org>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:42012 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbKIAqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 19:46:23 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 9 Nov 2015 10:46:21 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 34E9B2BB0051
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 11:46:18 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tA90k4QU37880048
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:46:12 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tA90jjYG015408
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:45:45 +1100
Content-Disposition: inline
In-Reply-To: <1447029035.8727.27.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2015 at 11:30:35AM +1100, Benjamin Herrenschmidt wrote:
>On Mon, 2015-11-09 at 11:10 +1100, Gavin Shan wrote:
>> This replaces variable name "use_nc_si" with "use_ncsi". No logical
>> changes introduced.
>
>This driver patch is against an internal tree, not upstream. Please
>ignore. The upstream driver doesn't have any concept of "nc_si".
>
>Gavin, next time you respin the series, make sure it's against
>upstream.
>

Sure, Will do.

Thanks,
Gavin

>Cheers,
>Ben.
>
>> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>> ---
>> =A0drivers/net/ethernet/faraday/ftgmac100.c | 14 +++++++-------
>> =A01 file changed, 7 insertions(+), 7 deletions(-)
>>=20
>> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c
>> b/drivers/net/ethernet/faraday/ftgmac100.c
>> index 08e0336..778bee8 100644
>> --- a/drivers/net/ethernet/faraday/ftgmac100.c
>> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
>> @@ -75,7 +75,7 @@ struct ftgmac100 {
>> =A0	struct phy_device *phydev;
>> =A0	int old_speed;
>> =A0
>> -	bool use_nc_si;
>> +	bool use_ncsi;
>> =A0};
>> =A0
>> =A0static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
>> @@ -1150,11 +1150,11 @@ static int ftgmac100_open(struct net_device
>> *netdev)
>> =A0		goto err_hw;
>> =A0
>> =A0	ftgmac100_init_hw(priv);
>> -	ftgmac100_start_hw(priv, priv->use_nc_si ? 100 : 10);
>> +	ftgmac100_start_hw(priv, priv->use_ncsi ? 100 : 10);
>> =A0
>> =A0	if (priv->phydev)
>> =A0		phy_start(priv->phydev);
>> -	else if (priv->use_nc_si)
>> +	else if (priv->use_ncsi)
>> =A0		netif_carrier_on(priv->netdev);
>> =A0
>> =A0	napi_enable(&priv->napi);
>> @@ -1275,7 +1275,7 @@ err_alloc_mdiobus:
>> =A0
>> =A0static void ftgmac100_destroy_mdio(struct ftgmac100 *priv)
>> =A0{
>> -	if (!priv->use_nc_si)
>> +	if (!priv->use_ncsi)
>> =A0		return;
>> =A0	phy_disconnect(priv->phydev);
>> =A0	mdiobus_unregister(priv->mii_bus);
>> @@ -1359,9 +1359,9 @@ static int ftgmac100_probe(struct
>> platform_device *pdev)
>> =A0	/* Check for NC-SI mode */
>> =A0	if (pdev->dev.of_node &&
>> =A0	=A0=A0=A0=A0of_get_property(pdev->dev.of_node, "use-nc-si", NULL=
))
>> -		priv->use_nc_si =3D true;
>> +		priv->use_ncsi =3D true;
>> =A0	else
>> -		priv->use_nc_si =3D false;
>> +		priv->use_ncsi =3D false;
>> =A0
>> =A0	/* If we use NC-SI, we need to set that up, which isn't
>> implemented yet
>> =A0	=A0* so we pray things were setup by the bootloader and just
>> mark our link
>> @@ -1370,7 +1370,7 @@ static int ftgmac100_probe(struct
>> platform_device *pdev)
>> =A0	=A0* Eventually, we'll have a proper NC-SI stack as a helper
>> we can
>> =A0	=A0* instanciate
>> =A0	=A0*/
>> -	if (priv->use_nc_si) {
>> +	if (priv->use_ncsi) {
>> =A0		/* XXX */
>> =A0		priv->phydev =3D NULL;
>> =A0		dev_info(&pdev->dev, "Using NC-SI interface\n");
>
