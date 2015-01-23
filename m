From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: stmmac: add fixed_phy and phy_addr support using
 DT file
Date: Thu, 22 Jan 2015 20:15:25 -0800
Message-ID: <54C1CADD.4060103@gmail.com>
References: <1421980893-14475-1-git-send-email-ming.lei@canonical.com> <1421980893-14475-3-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	Byungho An <bh74.an@samsung.com>, Kukjin Kim <kgene@kernel.org>
To: linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:54450 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbbAWEP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 23:15:28 -0500
In-Reply-To: <1421980893-14475-3-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/01/2015 18:41, Ming Lei a =E9crit :
> From: Byungho An <bh74.an@samsung.com>
>=20
> This patch adds codes for DT file support, fixed_phy and phy_addr=20
> can be set in DT file.
>=20
> Signed-off-by: Byungho An <bh74.an@samsung.com> (bypass check for
> fixed phy) Signed-off-by: Ming Lei<ming.lei@canonical.com> ---=20
> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    5 ++++-=20
> .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    7 +++++++ 2
> files changed, 11 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c index
> 8c6b7c16..ddb4351 100644 ---
> a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c +++
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c @@ -847,8
> +847,11 @@ static int stmmac_init_phy(struct net_device *dev) * 0
> rather than 0xffff. Catch this here and treat 0 as a non-existent *
> device as well. * Note: phydev->phy_id is the result of reading the
> UID PHY registers. +	 * But phy_id returned from fixed phy is
> always zero, so bypass the +	 * check for fixed phy. */ -	if
> (phydev->phy_id =3D=3D 0) { +	if (phydev->phy_id =3D=3D 0 &&
> (!priv->plat->phy_bus_name || +
> strcmp(priv->plat->phy_bus_name,"fixed"))) {=20
> phy_disconnect(phydev); return -ENODEV; } diff --git
> a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c index
> 879e29f..4f11491 100644 ---
> a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c +++
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c @@ -128,6
> +128,7 @@ static int stmmac_probe_config_dt(struct platform_device
> *pdev, struct device_node *np =3D pdev->dev.of_node; struct
> stmmac_dma_cfg *dma_cfg; const struct of_device_id *device; +	u32
> phy_addr;
>=20
> if (!np) return -ENODEV; @@ -217,6 +218,12 @@ static int
> stmmac_probe_config_dt(struct platform_device *pdev, plat->pmt =3D
> 1; }
>=20
> +	if (of_find_property(np, "fixed_phy", NULL)) { +
> plat->phy_bus_name =3D "fixed"; +		of_property_read_u32(np,
> "phy_addr", &phy_addr); +		plat->phy_addr =3D phy_addr; +	}

Humm, same here, it would look like you could use the existing Device
Tree helpers for parsing and registering a fixed PHY here, provided
that you use the proper binding though.

BTW, Ming Lei's email is bouncing, do we have an updated email he
could be contacted with?

> + if (of_device_is_compatible(np, "snps,dwmac-3.610") ||=20
> of_device_is_compatible(np, "snps,dwmac-3.710")) { plat->enh_desc =3D
> 1;
>=20


--=20
=46lorian
