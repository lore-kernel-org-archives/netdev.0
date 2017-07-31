From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next] net: fec: Issue error for missing but expected
 PHY
Date: Mon, 31 Jul 2017 01:42:48 +0000
Message-ID: <VI1PR0401MB22711000D5299C323189FD0BFFB20@VI1PR0401MB2271.eurprd04.prod.outlook.com>
References: <1501445466-23518-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0048.outbound.protection.outlook.com ([104.47.2.48]:11461
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751246AbdGaBmv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 21:42:51 -0400
In-Reply-To: <1501445466-23518-1-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch> Sent: Monday, July 31, 2017 4:11 AM
>If the PHY is missing but expected, e.g. because of a typ0 in the dt file,=
 it is not
>possible to open the interface. ip link returns:
>
>RTNETLINK answers: No such device
>
>It is not very obvious what the problem is. Add a netdev_err() in this cas=
e to
>make it easier to debug the issue.
>
>[   21.409385] fec 2188000.ethernet eth0: Unable to connect to phy
>RTNETLINK answers: No such device
>
>Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Fugang Duan <fugang.duan@nxp.com>

>---
> drivers/net/ethernet/freescale/fec_main.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/freescale/fec_main.c
>b/drivers/net/ethernet/freescale/fec_main.c
>index cc0c2a58c4de..c5995f07f821 100644
>--- a/drivers/net/ethernet/freescale/fec_main.c
>+++ b/drivers/net/ethernet/freescale/fec_main.c
>@@ -1907,8 +1907,10 @@ static int fec_enet_mii_probe(struct net_device
>*ndev)
> 		phy_dev =3D of_phy_connect(ndev, fep->phy_node,
> 					 &fec_enet_adjust_link, 0,
> 					 fep->phy_interface);
>-		if (!phy_dev)
>+		if (!phy_dev) {
>+			netdev_err(ndev, "Unable to connect to phy\n");
> 			return -ENODEV;
>+		}
> 	} else {
> 		/* check for attached phy */
> 		for (phy_id =3D 0; (phy_id < PHY_MAX_ADDR); phy_id++) {
>--
>2.13.2
