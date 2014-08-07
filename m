From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: fs_enet: fix reference counting for phy_node
Date: Thu,  7 Aug 2014 23:06:00 +0200
Message-ID: <1407445560-20500-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, kernel@pengutronix.de
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53165 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696AbaHGVGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 17:06:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure that fs_enet_probe is left with a reference to the phy node.
In the presence of a phy handle this is already the case as
of_parse_phandle returns a reference. In the fixed phy case a call to
of_node_get is necessary. Otherwise the error path and remove function
drop a reference the driver isn't holding.

=46ixes: bb74d9a4a87b ("fs_enet: use the new fixed PHY helpers")
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/dr=
ivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index cfaf17b70f3f..748fd24d3d9e 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1033,7 +1033,7 @@ static int fs_enet_probe(struct platform_device *=
ofdev)
 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
 		 */
-		fpi->phy_node =3D ofdev->dev.of_node;
+		fpi->phy_node =3D of_node_get(ofdev->dev.of_node);
 	}
=20
 	if (of_device_is_compatible(ofdev->dev.of_node, "fsl,mpc5125-fec")) {
--=20
2.0.1
