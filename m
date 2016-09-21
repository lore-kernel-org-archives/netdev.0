From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] net: fec: set mac address unconditionally
Date: Wed, 21 Sep 2016 16:26:02 +0000
Message-ID: <AM4PR0401MB2260AB54A9A0B96F01D5DA21FFF60@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1474464655-126940-1-git-send-email-g.schenk@eckelmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel@pengutronix.de" <kernel@pengutronix.de>
To: Gavin Schenk <g.schenk@eckelmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0073.outbound.protection.outlook.com ([104.47.2.73]:35126
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755315AbcIUSAf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 14:00:35 -0400
In-Reply-To: <1474464655-126940-1-git-send-email-g.schenk@eckelmann.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Schenk <g.schenk@eckelmann.de> Sent: Wednesday, September 21, 2=
016 9:31 PM
> To: Andy Duan <fugang.duan@nxp.com>
> Cc: netdev@vger.kernel.org; kernel@pengutronix.de; Gavin Schenk
> <g.schenk@eckelmann.de>
> Subject: [PATCH] net: fec: set mac address unconditionally
>=20
> Fixes: 9638d19e4816 ("net: fec: add netif status check before set mac
> address")
>=20
> If the mac address origin is not dt, you can only safe assign a mac addre=
ss
> after "link up" of the device. If the link is down the clocks are disable=
d and
> because of issues assigning registers when clocks are down the new mac
> address is discarded on some soc's. This fix sets the mac address
> unconditionally in fec_restart(...) and ensures consistens between fec
> registers and the network layer.
>=20
> Signed-off-by: Gavin Schenk <g.schenk@eckelmann.de>
> ---

It make sense, thanks.

Acked-by: Fugang Duan <fugang.duan@nxp.com>

>  drivers/net/ethernet/freescale/fec_main.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 2a03857cca18..bdabea6cd981 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -903,13 +903,11 @@ fec_restart(struct net_device *ndev)
>  	 * enet-mac reset will reset mac address registers too,
>  	 * so need to reconfigure it.
>  	 */
> -	if (fep->quirks & FEC_QUIRK_ENET_MAC) {
> -		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
> -		writel((__force u32)cpu_to_be32(temp_mac[0]),
> -		       fep->hwp + FEC_ADDR_LOW);
> -		writel((__force u32)cpu_to_be32(temp_mac[1]),
> -		       fep->hwp + FEC_ADDR_HIGH);
> -	}
> +	memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
> +	writel((__force u32)cpu_to_be32(temp_mac[0]),
> +	       fep->hwp + FEC_ADDR_LOW);
> +	writel((__force u32)cpu_to_be32(temp_mac[1]),
> +	       fep->hwp + FEC_ADDR_HIGH);
>=20
>  	/* Clear any outstanding interrupt. */
>  	writel(0xffffffff, fep->hwp + FEC_IEVENT);
> --
> 1.9.1
>=20
>=20
> Eckelmann AG
> Vorstand: Dipl.-Ing. Peter Frankenbach (Sprecher) Dipl.-Wi.-Ing. Philipp
> Eckelmann
> Dr.-Ing. Frank-Thomas Mellert Dr.-Ing. Marco M=FCnchhof Dr.-Ing. Frank
> Uhlemann
> Vorsitzender des Aufsichtsrats: Hubertus G. Krossa
> Sitz der Gesellschaft: Berliner Str. 161, 65205 Wiesbaden, Amtsgericht
> Wiesbaden HRB 12636
> http://www.eckelmann.de
