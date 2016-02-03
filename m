From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH net-next] sxgbe: remove unused code
Date: Wed, 3 Feb 2016 14:49:46 -0700
Message-ID: <56B275FA.40608@osg.samsung.com>
References: <1454530267-12712-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shuahkhan@gmail.com, julia.lawall@lip6.fr,
	Byungho An <bh74.an@samsung.com>,
	Girish K S <ks.giri@samsung.com>,
	Shuah Khan <shuahkh@osg.samsung.com>
To: =?UTF-8?Q?J=ce=b5an_Sacren?= <sakiwit@gmail.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:54252 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965075AbcBCVtx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 16:49:53 -0500
In-Reply-To: <1454530267-12712-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 01:11 PM, J=CE=B5an Sacren wrote:
> From: Jean Sacren <sakiwit@gmail.com>
>=20
> With the introduction of this commit 1edb9ca69e8a
> ("net: sxgbe: add basic framework for Samsung 10Gb ethernet driver"),
> the following interface was added:
>=20
> 	int sxgbe_xpcs_init(struct net_device *ndev);
> 	int sxgbe_xpcs_init_1G(struct net_device *ndev);
>=20
> But those two functions have never been used since the inception.
>=20
> In addition to the interface, the following macros are defined in
> sxgbe_xpcs header but not used:
>=20
> 	SR_MII_MMD_AN_ADV
> 	SR_MII_MMD_AN_LINK_PARTNER_BA
> 	VR_MII_MMD_AN_CONTROL
> 	VR_MII_MMD_AN_INT_STATUS
> 	XPCS_TYPE_SEL_R
> 	XPCS_TYPE_SEL_W
> 	XPCS_RXAUI_MODE
>=20
> If we remove the interface, functions it uses and all other macros
> defined in sxgbe_xpcs header will also become useless. Thus, the whol=
e
> sxgbe_xpcs shebang should be all gone.
>=20
> Julia Lawall observed:
>=20
> "...  I was looking at dependencies between networking files.  This o=
ne
> stands out because nothing is dependent[ ]on it, even the files it is
> compiled with, and it doesn't contain the usual functions,
> register_netdev, etc."
>=20
> David Miller commented:
>=20
> "There are no in-tree callers of this code.  It should be removed unt=
il
> there are in-tree users.
>=20
> Nobody can figure out if the interface for this is done properly with=
out
> seeing the call sites and how they work.  It is therefore impossible =
to
> review this code and judge it[']s design."
>=20
> Let's remove this unused code. As a matter of fact, it should not hav=
e
> been merged in the first place.

ok - I don't think all of this belongs in the change log.
You can just say - "removing unused code" include a link
a to the discussion - could also add Suggested-by tag for
David Miller

thanks,
-- Shuah
>=20
> Reported-by: Julia Lawall <julia.lawall@lip6.fr>
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Byungho An <bh74.an@samsung.com>
> Cc: Girish K S <ks.giri@samsung.com>
> ---
> We may use "--ignore FILE_PATH_CHANGES" to suppress checkpatch warnin=
g.
>=20
>  drivers/net/ethernet/samsung/sxgbe/Makefile     |  2 +-
>  drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c | 91 ---------------=
----------
>  drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h | 38 -----------
>  3 files changed, 1 insertion(+), 130 deletions(-)
>  delete mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
>  delete mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h
>=20
> diff --git a/drivers/net/ethernet/samsung/sxgbe/Makefile b/drivers/ne=
t/ethernet/samsung/sxgbe/Makefile
> index dcc80b9d4370..31e968561d5c 100644
> --- a/drivers/net/ethernet/samsung/sxgbe/Makefile
> +++ b/drivers/net/ethernet/samsung/sxgbe/Makefile
> @@ -1,4 +1,4 @@
>  obj-$(CONFIG_SXGBE_ETH) +=3D samsung-sxgbe.o
>  samsung-sxgbe-objs:=3D sxgbe_platform.o sxgbe_main.o sxgbe_desc.o \
>  		sxgbe_dma.o sxgbe_core.o sxgbe_mtl.o  sxgbe_mdio.o \
> -		sxgbe_ethtool.o sxgbe_xpcs.o $(samsung-sxgbe-y)
> +		sxgbe_ethtool.o $(samsung-sxgbe-y)
> diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c b/driver=
s/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
> deleted file mode 100644
> index 51c32194ba88..000000000000
> --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
> +++ /dev/null
> @@ -1,91 +0,0 @@
> -/* 10G controller driver for Samsung SoCs
> - *
> - * Copyright (C) 2013 Samsung Electronics Co., Ltd.
> - *		http://www.samsung.com
> - *
> - * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
> - *
> - * This program is free software; you can redistribute it and/or mod=
ify
> - * it under the terms of the GNU General Public License version 2 as
> - * published by the Free Software Foundation.
> - */
> -#include <linux/bitops.h>
> -#include <linux/kernel.h>
> -#include <linux/netdevice.h>
> -#include <linux/phy.h>
> -#include "sxgbe_common.h"
> -#include "sxgbe_xpcs.h"
> -
> -static int sxgbe_xpcs_read(struct net_device *ndev, unsigned int reg=
)
> -{
> -	u32 value;
> -	struct sxgbe_priv_data *priv =3D netdev_priv(ndev);
> -
> -	value =3D readl(priv->ioaddr + XPCS_OFFSET + reg);
> -
> -	return value;
> -}
> -
> -static int sxgbe_xpcs_write(struct net_device *ndev, int reg, int da=
ta)
> -{
> -	struct sxgbe_priv_data *priv =3D netdev_priv(ndev);
> -
> -	writel(data, priv->ioaddr + XPCS_OFFSET + reg);
> -
> -	return 0;
> -}
> -
> -int sxgbe_xpcs_init(struct net_device *ndev)
> -{
> -	u32 value;
> -
> -	value =3D sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
> -	/* 10G XAUI mode */
> -	sxgbe_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
> -	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE=
);
> -	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, value | BIT(13=
));
> -	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
> -
> -	do {
> -		value =3D sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
> -	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) =3D=3D XPCS_QSEQ_STATE_S=
TABLE);
> -
> -	value =3D sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
> -	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(11));
> -
> -	do {
> -		value =3D sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
> -	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) !=3D XPCS_QSEQ_STATE_STA=
BLE);
> -
> -	return 0;
> -}
> -
> -int sxgbe_xpcs_init_1G(struct net_device *ndev)
> -{
> -	int value;
> -
> -	/* 10GBASE-X PCS (1G) mode */
> -	sxgbe_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
> -	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE=
);
> -	value =3D sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
> -	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(13));
> -
> -	value =3D sxgbe_xpcs_read(ndev, SR_MII_MMD_CONTROL);
> -	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value | BIT(6));
> -	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value & ~BIT(13));
> -	value =3D sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
> -	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
> -
> -	do {
> -		value =3D sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
> -	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) !=3D XPCS_QSEQ_STATE_STA=
BLE);
> -
> -	value =3D sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
> -	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(11));
> -
> -	/* Auto Negotiation cluase 37 enable */
> -	value =3D sxgbe_xpcs_read(ndev, SR_MII_MMD_CONTROL);
> -	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value | BIT(12));
> -
> -	return 0;
> -}
> diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h b/driver=
s/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h
> deleted file mode 100644
> index 6b26a50724d3..000000000000
> --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h
> +++ /dev/null
> @@ -1,38 +0,0 @@
> -/* 10G controller driver for Samsung SoCs
> - *
> - * Copyright (C) 2013 Samsung Electronics Co., Ltd.
> - *		http://www.samsung.com
> - *
> - * Author: Byungho An <bh74.an@samsung.com>
> - *
> - * This program is free software; you can redistribute it and/or mod=
ify
> - * it under the terms of the GNU General Public License version 2 as
> - * published by the Free Software Foundation.
> - */
> -#ifndef __SXGBE_XPCS_H__
> -#define __SXGBE_XPCS_H__
> -
> -/* XPCS Registers */
> -#define XPCS_OFFSET			0x1A060000
> -#define SR_PCS_MMD_CONTROL1		0x030000
> -#define SR_PCS_CONTROL2			0x030007
> -#define VR_PCS_MMD_XAUI_MODE_CONTROL	0x038004
> -#define VR_PCS_MMD_DIGITAL_STATUS	0x038010
> -#define SR_MII_MMD_CONTROL		0x1F0000
> -#define SR_MII_MMD_AN_ADV		0x1F0004
> -#define SR_MII_MMD_AN_LINK_PARTNER_BA	0x1F0005
> -#define VR_MII_MMD_AN_CONTROL		0x1F8001
> -#define VR_MII_MMD_AN_INT_STATUS	0x1F8002
> -
> -#define XPCS_QSEQ_STATE_STABLE		0x10
> -#define XPCS_QSEQ_STATE_MPLLOFF		0x1c
> -#define XPCS_TYPE_SEL_R			0x00
> -#define XPCS_TYPE_SEL_X			0x01
> -#define XPCS_TYPE_SEL_W			0x02
> -#define XPCS_XAUI_MODE			0x00
> -#define XPCS_RXAUI_MODE			0x01
> -
> -int sxgbe_xpcs_init(struct net_device *ndev);
> -int sxgbe_xpcs_init_1G(struct net_device *ndev);
> -
> -#endif /* __SXGBE_XPCS_H__ */
>=20


--=20
Shuah Khan
Sr. Linux Kernel Developer
Open Source Innovation Group
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
