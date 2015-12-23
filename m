From: Henri Roosen <henri.roosen@ginzinger.com>
Subject: [PATCH v2 1/1] phy: micrel: Fix finding PHY properties in MAC node for KSZ9031.
Date: Wed, 23 Dec 2015 11:42:29 +0100
Message-ID: <1450867349-9436-1-git-send-email-henri.roosen@ginzinger.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<andrew@lunn.ch>, Henri Roosen <henri.roosen@ginzinger.com>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 651df2183543 ("phy: micrel: Fix finding PHY properties in MAC
 node.") only fixes finding PHY properties in MAC node for KSZ9021. This
commit applies the same fix for KSZ9031.

Signed-off-by: Henri Roosen <henri.roosen@ginzinger.com>
---
 drivers/net/phy/micrel.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index e13ad6c..fc6c058 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -470,9 +470,18 @@ static int ksz9031_config_init(struct phy_device *phydev)
 		"txd2-skew-ps", "txd3-skew-ps"
 	};
 	static const char *control_skews[2] = {"txen-skew-ps", "rxdv-skew-ps"};
+	const struct device *dev_walker;
 
-	if (!of_node && dev->parent->of_node)
-		of_node = dev->parent->of_node;
+	/* The Micrel driver has a deprecated option to place phy OF
+	 * properties in the MAC node. Walk up the tree of devices to
+	 * find a device with an OF node.
+	 */
+	dev_walker = &phydev->dev;
+	do {
+		of_node = dev_walker->of_node;
+		dev_walker = dev_walker->parent;
+
+	} while (!of_node && dev_walker);
 
 	if (of_node) {
 		ksz9031_of_load_skew_values(phydev, of_node,
-- 
2.1.4
