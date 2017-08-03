From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v3 net-next 4/5] net: dsa: lan9303: Rename lan9303_xxx_packet_processing()
Date: Thu,  3 Aug 2017 11:45:06 +0200
Message-ID: <20170803094507.3439-5-privat@egil-hjelmeland.no>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803094507.3439-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The lan9303_enable_packet_processing, lan9303_disable_packet_processing
functions operate on port, so the names should reflect that.
And to align with lan9303_disable_processing(), rename:

lan9303_enable_packet_processing -> lan9303_enable_processing_port
lan9303_disable_packet_processing -> lan9303_disable_processing_port

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 31fe66fbe39a..6f409755ba1a 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -465,8 +465,8 @@ static int lan9303_detect_phy_setup(struct lan9303 *chip)
 	return 0;
 }
 
-static int lan9303_disable_packet_processing(struct lan9303 *chip,
-					     unsigned int port)
+static int lan9303_disable_processing_port(struct lan9303 *chip,
+					   unsigned int port)
 {
 	int ret;
 
@@ -484,8 +484,8 @@ static int lan9303_disable_packet_processing(struct lan9303 *chip,
 			LAN9303_MAC_TX_CFG_X_TX_PAD_ENABLE);
 }
 
-static int lan9303_enable_packet_processing(struct lan9303 *chip,
-					    unsigned int port)
+static int lan9303_enable_processing_port(struct lan9303 *chip,
+					  unsigned int port)
 {
 	int ret;
 
@@ -567,7 +567,7 @@ static int lan9303_disable_processing(struct lan9303 *chip)
 	int p;
 
 	for (p = 0; p < LAN9303_NUM_PORTS; p++) {
-		int ret = lan9303_disable_packet_processing(chip, p);
+		int ret = lan9303_disable_processing_port(chip, p);
 
 		if (ret)
 			return ret;
@@ -643,7 +643,7 @@ static int lan9303_setup(struct dsa_switch *ds)
 	if (ret)
 		dev_err(chip->dev, "failed to separate ports %d\n", ret);
 
-	ret = lan9303_enable_packet_processing(chip, 0);
+	ret = lan9303_enable_processing_port(chip, 0);
 	if (ret)
 		dev_err(chip->dev, "failed to re-enable switching %d\n", ret);
 
@@ -767,7 +767,7 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
 	switch (port) {
 	case 1:
 	case 2:
-		return lan9303_enable_packet_processing(chip, port);
+		return lan9303_enable_processing_port(chip, port);
 	default:
 		dev_dbg(chip->dev,
 			"Error: request to power up invalid port %d\n", port);
@@ -785,7 +785,7 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	switch (port) {
 	case 1:
 	case 2:
-		lan9303_disable_packet_processing(chip, port);
+		lan9303_disable_processing_port(chip, port);
 		lan9303_phy_write(ds, chip->phy_addr_sel_strap + port,
 				  MII_BMCR, BMCR_PDOWN);
 		break;
-- 
2.11.0
