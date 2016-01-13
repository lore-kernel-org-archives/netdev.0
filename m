From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: fsl/fman: Clarification for implementation details in dtsec_config()
Date: Wed, 13 Jan 2016 22:20:45 +0100
Message-ID: <5696BFAD.9030905@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Igal Liberman <igal.liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

The Coccinelle semantic patch "deref_null.cocci" pointed out a potentia=
l
problem in the implementation of the function "dtsec_config" (lines 143=
4-1439):
https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/d=
rivers/net/ethernet/freescale/fman/fman_dtsec.c?id=3De5a03bfd873c29eb78=
6655ef2e95e53ed242b404#n1434
=E2=80=A6
	dtsec->tbiphy =3D of_phy_find_device(params->internal_phy_node);
	if (!dtsec->tbiphy) {
		pr_err("of_phy_find_device (TBI PHY) failed\n");
		put_device(&dtsec->tbiphy->mdio.dev);
		goto err_dtsec_drv_param;
	}
=E2=80=A6

If the pointer "dtsec->tbiphy" is NULL, then it will especially matter
if the shown address computation will succeed.
Should the call of the function "put_device" be removed,
or was another argument intended?

Regards,
Markus
