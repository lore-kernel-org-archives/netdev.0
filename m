From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 1/2] net: dsa: lan9303: Move struct lan9303 to include/linux/lan9303.h
Date: Tue, 24 Oct 2017 11:35:14 +0200
Message-ID: <20171024093515.6749-2-privat@egil-hjelmeland.no>
References: <20171024093515.6749-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:59934 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751363AbdJXJfe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 05:35:34 -0400
In-Reply-To: <20171024093515.6749-1-privat@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The next patch require net/dsa/tag_lan9303.c to access struct lan9303.
Therefore move struct lan9303 definitions from drivers/net/dsa/lan9303.h
to new file include/linux/lan9303.h.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 MAINTAINERS               |  1 +
 drivers/net/dsa/lan9303.h | 34 +---------------------------------
 include/linux/lan9303.h   | 35 +++++++++++++++++++++++++++++++++++
 3 files changed, 37 insertions(+), 33 deletions(-)
 create mode 100644 include/linux/lan9303.h

diff --git a/MAINTAINERS b/MAINTAINERS
index e3a7ca9d2783..9535e32bd421 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9416,6 +9416,7 @@ S:	Maintained
 F:	net/dsa/
 F:	include/net/dsa.h
 F:	drivers/net/dsa/
+F:	include/linux/lan9303.h
 
 NETWORKING [GENERAL]
 M:	"David S. Miller" <davem@davemloft.net>
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index d807b1be35f2..e6675e11c833 100644
--- a/drivers/net/dsa/lan9303.h
+++ b/drivers/net/dsa/lan9303.h
@@ -2,39 +2,7 @@
 #include <linux/device.h>
 #include <net/dsa.h>
 
-struct lan9303;
-
-struct lan9303_phy_ops {
-	/* PHY 1 and 2 access*/
-	int	(*phy_read)(struct lan9303 *chip, int port, int regnum);
-	int	(*phy_write)(struct lan9303 *chip, int port,
-			     int regnum, u16 val);
-};
-
-#define LAN9303_NUM_ALR_RECORDS 512
-struct lan9303_alr_cache_entry {
-	u8  mac_addr[ETH_ALEN];
-	u8  port_map;           /* Bitmap of ports. Zero if unused entry */
-	u8  stp_override;       /* non zero if set ALR_DAT1_AGE_OVERRID */
-};
-
-struct lan9303 {
-	struct device *dev;
-	struct regmap *regmap;
-	struct regmap_irq_chip_data *irq_data;
-	struct gpio_desc *reset_gpio;
-	u32 reset_duration; /* in [ms] */
-	bool phy_addr_sel_strap;
-	struct dsa_switch *ds;
-	struct mutex indirect_mutex; /* protect indexed register access */
-	const struct lan9303_phy_ops *ops;
-	bool is_bridged; /* true if port 1 and 2 are bridged */
-	u32 swe_port_state; /* remember SWE_PORT_STATE while not bridged */
-	/* LAN9303 do not offer reading specific ALR entry. Cache all
-	 * static entries in a flat table
-	 **/
-	struct lan9303_alr_cache_entry alr_cache[LAN9303_NUM_ALR_RECORDS];
-};
+#include <linux/lan9303.h>
 
 extern const struct regmap_access_table lan9303_register_set;
 extern const struct lan9303_phy_ops lan9303_indirect_phy_ops;
diff --git a/include/linux/lan9303.h b/include/linux/lan9303.h
new file mode 100644
index 000000000000..5810bdb43581
--- /dev/null
+++ b/include/linux/lan9303.h
@@ -0,0 +1,35 @@
+/* Included by drivers/net/dsa/lan9303.h and net/dsa/tag_lan9303.c */
+
+struct lan9303;
+
+struct lan9303_phy_ops {
+	/* PHY 1 and 2 access*/
+	int	(*phy_read)(struct lan9303 *chip, int port, int regnum);
+	int	(*phy_write)(struct lan9303 *chip, int port,
+			     int regnum, u16 val);
+};
+
+#define LAN9303_NUM_ALR_RECORDS 512
+struct lan9303_alr_cache_entry {
+	u8  mac_addr[ETH_ALEN];
+	u8  port_map;           /* Bitmap of ports. Zero if unused entry */
+	u8  stp_override;       /* non zero if set ALR_DAT1_AGE_OVERRID */
+};
+
+struct lan9303 {
+	struct device *dev;
+	struct regmap *regmap;
+	struct regmap_irq_chip_data *irq_data;
+	struct gpio_desc *reset_gpio;
+	u32 reset_duration; /* in [ms] */
+	bool phy_addr_sel_strap;
+	struct dsa_switch *ds;
+	struct mutex indirect_mutex; /* protect indexed register access */
+	const struct lan9303_phy_ops *ops;
+	bool is_bridged; /* true if port 1 and 2 are bridged */
+	u32 swe_port_state; /* remember SWE_PORT_STATE while not bridged */
+	/* LAN9303 do not offer reading specific ALR entry. Cache all
+	 * static entries in a flat table
+	 **/
+	struct lan9303_alr_cache_entry alr_cache[LAN9303_NUM_ALR_RECORDS];
+};
-- 
2.11.0
