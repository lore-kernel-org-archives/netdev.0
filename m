From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH v2] net: axinet: Use of_property_read_u32 instead of open-coding it
Date: Wed, 23 Sep 2015 09:20:55 +0200
Message-ID: <1442992855-6164-1-git-send-email-tklauser@distanz.ch>
References: <1442922357-18815-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:35627 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbbIWHU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 03:20:58 -0400
In-Reply-To: <1442922357-18815-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of_property_read_u32 instead of of_get_property with return value
checks and endianness conversion.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Reviewed-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
---
v2: Resending with Cc to netdev

 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c b/driver=
s/net/ethernet/xilinx/xilinx_axienet_mdio.c
index 2a5a168..507bbb0 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
@@ -129,7 +129,6 @@ int axienet_mdio_setup(struct axienet_local *lp, st=
ruct device_node *np)
 {
 	int ret;
 	u32 clk_div, host_clock;
-	u32 *property_p;
 	struct mii_bus *bus;
 	struct resource res;
 	struct device_node *np1;
@@ -168,8 +167,7 @@ int axienet_mdio_setup(struct axienet_local *lp, st=
ruct device_node *np)
 		clk_div =3D DEFAULT_CLOCK_DIVISOR;
 		goto issue;
 	}
-	property_p =3D (u32 *) of_get_property(np1, "clock-frequency", NULL);
-	if (!property_p) {
+	if (of_property_read_u32(np1, "clock-frequency", &host_clock)) {
 		netdev_warn(lp->ndev, "clock-frequency property not found.\n");
 		netdev_warn(lp->ndev,
 			    "Setting MDIO clock divisor to default %d\n",
@@ -179,7 +177,6 @@ int axienet_mdio_setup(struct axienet_local *lp, st=
ruct device_node *np)
 		goto issue;
 	}
=20
-	host_clock =3D be32_to_cpup(property_p);
 	clk_div =3D (host_clock / (MAX_MDIO_FREQ * 2)) - 1;
 	/* If there is any remainder from the division of
 	 * fHOST / (MAX_MDIO_FREQ * 2), then we need to add
--=20
2.5.0
