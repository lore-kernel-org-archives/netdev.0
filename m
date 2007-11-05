From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 4/5] ucc_geth: handle passing of RX-only and TX-only
 internal delay PHY connection type parameters
Date: Mon, 5 Nov 2007 12:15:47 -0600
Message-ID: <20071105121547.9b402c52.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, paulus@samba.org
To: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:33361 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399AbXKESQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 13:16:16 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extend the RGMII-Internal Delay specification case to include
TX-only and RX-only variants.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/ucc_geth.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index a3ff270..7f68990 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1460,6 +1460,8 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
 	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 		upsmr |= UPSMR_RPM;
 		switch (ugeth->max_speed) {
@@ -1557,6 +1559,8 @@ static void adjust_link(struct net_device *dev)
 				if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
 				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
 				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_ID) ||
+				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
+				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID) ||
 				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 					if (phydev->speed == SPEED_10)
 						upsmr |= UPSMR_R10M;
@@ -3795,6 +3799,10 @@ static phy_interface_t to_phy_interface(const char *phy_connection_type)
 		return PHY_INTERFACE_MODE_RGMII;
 	if (strcasecmp(phy_connection_type, "rgmii-id") == 0)
 		return PHY_INTERFACE_MODE_RGMII_ID;
+	if (strcasecmp(phy_connection_type, "rgmii-txid") == 0)
+		return PHY_INTERFACE_MODE_RGMII_TXID;
+	if (strcasecmp(phy_connection_type, "rgmii-rxid") == 0)
+		return PHY_INTERFACE_MODE_RGMII_RXID;
 	if (strcasecmp(phy_connection_type, "rtbi") == 0)
 		return PHY_INTERFACE_MODE_RTBI;
 
@@ -3889,6 +3897,8 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		case PHY_INTERFACE_MODE_GMII:
 		case PHY_INTERFACE_MODE_RGMII:
 		case PHY_INTERFACE_MODE_RGMII_ID:
+		case PHY_INTERFACE_MODE_RGMII_RXID:
+		case PHY_INTERFACE_MODE_RGMII_TXID:
 		case PHY_INTERFACE_MODE_TBI:
 		case PHY_INTERFACE_MODE_RTBI:
 			max_speed = SPEED_1000;
-- 
1.5.2.2

