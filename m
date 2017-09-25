From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v2 05/16] thunderbolt: Move tb_switch_phy_port_from_link() to thunderbolt.h
Date: Mon, 25 Sep 2017 14:07:27 +0300
Message-ID: <20170925110738.68382-6-mika.westerberg@linux.intel.com>
References: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A Thunderbolt service might need to find the physical port from a link
the cable is connected to. For instance networking driver uses this
information to generate MAC address according the Apple ThunderboltIP
protocol.

Move this function to thunderbolt.h and rename it to
tb_phy_port_from_link() to reflect the fact that it does not take switch
as parameter.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
---
 drivers/thunderbolt/icm.c   | 2 +-
 drivers/thunderbolt/tb.h    | 7 -------
 include/linux/thunderbolt.h | 7 +++++++
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/thunderbolt/icm.c b/drivers/thunderbolt/icm.c
index 53250fc057e1..8c22b91ed040 100644
--- a/drivers/thunderbolt/icm.c
+++ b/drivers/thunderbolt/icm.c
@@ -89,7 +89,7 @@ static inline struct tb *icm_to_tb(struct icm *icm)
 
 static inline u8 phy_port_from_route(u64 route, u8 depth)
 {
-	return tb_switch_phy_port_from_link(route >> ((depth - 1) * 8));
+	return tb_phy_port_from_link(route >> ((depth - 1) * 8));
 }
 
 static inline u8 dual_link_from_link(u8 link)
diff --git a/drivers/thunderbolt/tb.h b/drivers/thunderbolt/tb.h
index 2fefe76621ca..ea21d927bd09 100644
--- a/drivers/thunderbolt/tb.h
+++ b/drivers/thunderbolt/tb.h
@@ -40,8 +40,6 @@ struct tb_switch_nvm {
 };
 
 #define TB_SWITCH_KEY_SIZE		32
-/* Each physical port contains 2 links on modern controllers */
-#define TB_SWITCH_LINKS_PER_PHY_PORT	2
 
 /**
  * struct tb_switch - a thunderbolt switch
@@ -367,11 +365,6 @@ struct tb_switch *tb_switch_find_by_link_depth(struct tb *tb, u8 link,
 					       u8 depth);
 struct tb_switch *tb_switch_find_by_uuid(struct tb *tb, const uuid_t *uuid);
 
-static inline unsigned int tb_switch_phy_port_from_link(unsigned int link)
-{
-	return (link - 1) / TB_SWITCH_LINKS_PER_PHY_PORT;
-}
-
 static inline void tb_switch_put(struct tb_switch *sw)
 {
 	put_device(&sw->dev);
diff --git a/include/linux/thunderbolt.h b/include/linux/thunderbolt.h
index 910b1bf92112..43b8d1e09341 100644
--- a/include/linux/thunderbolt.h
+++ b/include/linux/thunderbolt.h
@@ -78,6 +78,13 @@ struct tb {
 
 extern struct bus_type tb_bus_type;
 
+#define TB_LINKS_PER_PHY_PORT	2
+
+static inline unsigned int tb_phy_port_from_link(unsigned int link)
+{
+	return (link - 1) / TB_LINKS_PER_PHY_PORT;
+}
+
 /**
  * struct tb_property_dir - XDomain property directory
  * @uuid: Directory UUID or %NULL if root directory
-- 
2.14.1
