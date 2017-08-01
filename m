From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 3/3] net: dsa: lan9303: Simplify lan9303_xxx_packet_processing() usage
Date: Tue,  1 Aug 2017 13:14:39 +0200
Message-ID: <20170801111439.1143-4-privat@egil-hjelmeland.no>
References: <20170801111439.1143-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801111439.1143-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify usage of lan9303_enable_packet_processing,
lan9303_disable_packet_processing()

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 2a3c6bf473dd..4da580c43751 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -564,15 +564,16 @@ static int lan9303_handle_reset(struct lan9303 *chip)
 /* stop processing packets for all ports */
 static int lan9303_disable_processing(struct lan9303 *chip)
 {
-	int ret;
+	int p;
 
-	ret = lan9303_disable_packet_processing(chip, 0);
-	if (ret)
-		return ret;
-	ret = lan9303_disable_packet_processing(chip, 1);
-	if (ret)
-		return ret;
-	return lan9303_disable_packet_processing(chip, 2);
+	for (p = 0; p < LAN9303_NUM_PORTS; p++) {
+		int ret = lan9303_disable_packet_processing(chip, p);
+
+		if (ret)
+			return ret;
+	}
+
+	return 0;
 }
 
 static int lan9303_check_device(struct lan9303 *chip)
@@ -765,7 +766,6 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
 	/* enable internal packet processing */
 	switch (port) {
 	case 1:
-		return lan9303_enable_packet_processing(chip, port);
 	case 2:
 		return lan9303_enable_packet_processing(chip, port);
 	default:
@@ -784,13 +784,9 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	/* disable internal packet processing */
 	switch (port) {
 	case 1:
-		lan9303_disable_packet_processing(chip, port);
-		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 1,
-				  MII_BMCR, BMCR_PDOWN);
-		break;
 	case 2:
 		lan9303_disable_packet_processing(chip, port);
-		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 2,
+		lan9303_phy_write(ds, chip->phy_addr_sel_strap + port,
 				  MII_BMCR, BMCR_PDOWN);
 		break;
 	default:
-- 
2.11.0
