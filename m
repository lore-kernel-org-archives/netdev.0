From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH v3 1/3] net/phy: micrel: Be more const correct
Date: Fri, 5 Jun 2015 17:40:44 -0500
Message-ID: <1433544046-17595-2-git-send-email-jaeden.amero@ni.com>
References: <1433544046-17595-1-git-send-email-jaeden.amero@ni.com>
Cc: Jaeden Amero <jaeden.amero@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433544046-17595-1-git-send-email-jaeden.amero@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a few places in this driver, we weren't using const where we could
have. Use const more.

In addition, change the arrays of strings in ksz9031_config_init() to be
not only const, but also static.

Signed-off-by: Jaeden Amero <jaeden.amero@ni.com>
---
 drivers/net/phy/micrel.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index ebdc357..59cc5d4 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -288,9 +288,10 @@ static int kszphy_config_init(struct phy_device *phydev)
 }
 
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
-				       struct device_node *of_node, u16 reg,
-				       char *field1, char *field2,
-				       char *field3, char *field4)
+				       const struct device_node *of_node,
+				       u16 reg,
+				       const char *field1, const char *field2,
+				       const char *field3, const char *field4)
 {
 	int val1 = -1;
 	int val2 = -2;
@@ -336,8 +337,8 @@ static int ksz9021_load_values_from_of(struct phy_device *phydev,
 
 static int ksz9021_config_init(struct phy_device *phydev)
 {
-	struct device *dev = &phydev->dev;
-	struct device_node *of_node = dev->of_node;
+	const struct device *dev = &phydev->dev;
+	const struct device_node *of_node = dev->of_node;
 
 	if (!of_node && dev->parent->of_node)
 		of_node = dev->parent->of_node;
@@ -389,9 +390,9 @@ static int ksz9031_extended_read(struct phy_device *phydev,
 }
 
 static int ksz9031_of_load_skew_values(struct phy_device *phydev,
-				       struct device_node *of_node,
+				       const struct device_node *of_node,
 				       u16 reg, size_t field_sz,
-				       char *field[], u8 numfields)
+				       const char *field[], u8 numfields)
 {
 	int val[4] = {-1, -2, -3, -4};
 	int matches = 0;
@@ -427,18 +428,18 @@ static int ksz9031_of_load_skew_values(struct phy_device *phydev,
 
 static int ksz9031_config_init(struct phy_device *phydev)
 {
-	struct device *dev = &phydev->dev;
-	struct device_node *of_node = dev->of_node;
-	char *clk_skews[2] = {"rxc-skew-ps", "txc-skew-ps"};
-	char *rx_data_skews[4] = {
+	const struct device *dev = &phydev->dev;
+	const struct device_node *of_node = dev->of_node;
+	static const char *clk_skews[2] = {"rxc-skew-ps", "txc-skew-ps"};
+	static const char *rx_data_skews[4] = {
 		"rxd0-skew-ps", "rxd1-skew-ps",
 		"rxd2-skew-ps", "rxd3-skew-ps"
 	};
-	char *tx_data_skews[4] = {
+	static const char *tx_data_skews[4] = {
 		"txd0-skew-ps", "txd1-skew-ps",
 		"txd2-skew-ps", "txd3-skew-ps"
 	};
-	char *control_skews[2] = {"txen-skew-ps", "rxdv-skew-ps"};
+	static const char *control_skews[2] = {"txen-skew-ps", "rxdv-skew-ps"};
 
 	if (!of_node && dev->parent->of_node)
 		of_node = dev->parent->of_node;
@@ -519,7 +520,7 @@ ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
 static int kszphy_probe(struct phy_device *phydev)
 {
 	const struct kszphy_type *type = phydev->drv->driver_data;
-	struct device_node *np = phydev->dev.of_node;
+	const struct device_node *np = phydev->dev.of_node;
 	struct kszphy_priv *priv;
 	struct clk *clk;
 	int ret;
-- 
2.1.4
