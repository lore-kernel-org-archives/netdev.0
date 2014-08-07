From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 3/3] net: ucc_geth: Don't use the MAC as PHY without a fixed link
Date: Thu,  7 Aug 2014 23:48:26 +0200
Message-ID: <1407448106-1819-3-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58445 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbaHGVs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 17:48:57 -0400
In-Reply-To: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This matches what the other drivers using fixed-link support do and
restores the behaviour before commit 87009814cdbb ("ucc_geth: use the
new fixed PHY helpers") for the affected device trees (i.e. no
phy-handle and no fixed-link).

=46ixes: 87009814cdbb ("ucc_geth: use the new fixed PHY helpers")
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/et=
hernet/freescale/ucc_geth.c
index a22ff770f9e5..07415a0df88c 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3787,15 +3787,14 @@ static int ucc_geth_probe(struct platform_devic=
e* ofdev)
 	ug_info->uf_info.irq =3D irq_of_parse_and_map(np, 0);
=20
 	ug_info->phy_node =3D of_parse_phandle(np, "phy-handle", 0);
-	if (!ug_info->phy_node) {
-		/* In the case of a fixed PHY, the DT node associated
+	if (!ug_info->phy_node && of_phy_is_fixed_link(np)) {
+		/*
+		 * In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
 		 */
-		if (of_phy_is_fixed_link(np)) {
-			err =3D of_phy_register_fixed_link(np);
-			if (err)
-				return err;
-		}
+		err =3D of_phy_register_fixed_link(np);
+		if (err)
+			return err;
 		ug_info->phy_node =3D of_node_get(np);
 	}
=20
--=20
2.0.1
