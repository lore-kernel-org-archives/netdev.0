From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v2 04/16] thunderbolt: Move thunderbolt domain structure to thunderbolt.h
Date: Mon, 25 Sep 2017 14:07:26 +0300
Message-ID: <20170925110738.68382-5-mika.westerberg@linux.intel.com>
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

These are needed by Thunderbolt services so move them to thunderbolt.h
to make sure they are available outside of drivers/thunderbolt.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
---
 drivers/thunderbolt/tb.h    | 42 ------------------------------------------
 include/linux/thunderbolt.h | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 42 deletions(-)

diff --git a/drivers/thunderbolt/tb.h b/drivers/thunderbolt/tb.h
index e0deee4f1eb0..2fefe76621ca 100644
--- a/drivers/thunderbolt/tb.h
+++ b/drivers/thunderbolt/tb.h
@@ -39,20 +39,6 @@ struct tb_switch_nvm {
 	bool authenticating;
 };
 
-/**
- * enum tb_security_level - Thunderbolt security level
- * @TB_SECURITY_NONE: No security, legacy mode
- * @TB_SECURITY_USER: User approval required at minimum
- * @TB_SECURITY_SECURE: One time saved key required at minimum
- * @TB_SECURITY_DPONLY: Only tunnel Display port (and USB)
- */
-enum tb_security_level {
-	TB_SECURITY_NONE,
-	TB_SECURITY_USER,
-	TB_SECURITY_SECURE,
-	TB_SECURITY_DPONLY,
-};
-
 #define TB_SWITCH_KEY_SIZE		32
 /* Each physical port contains 2 links on modern controllers */
 #define TB_SWITCH_LINKS_PER_PHY_PORT	2
@@ -223,33 +209,6 @@ struct tb_cm_ops {
 	int (*disconnect_pcie_paths)(struct tb *tb);
 };
 
-/**
- * struct tb - main thunderbolt bus structure
- * @dev: Domain device
- * @lock: Big lock. Must be held when accessing any struct
- *	  tb_switch / struct tb_port.
- * @nhi: Pointer to the NHI structure
- * @ctl: Control channel for this domain
- * @wq: Ordered workqueue for all domain specific work
- * @root_switch: Root switch of this domain
- * @cm_ops: Connection manager specific operations vector
- * @index: Linux assigned domain number
- * @security_level: Current security level
- * @privdata: Private connection manager specific data
- */
-struct tb {
-	struct device dev;
-	struct mutex lock;
-	struct tb_nhi *nhi;
-	struct tb_ctl *ctl;
-	struct workqueue_struct *wq;
-	struct tb_switch *root_switch;
-	const struct tb_cm_ops *cm_ops;
-	int index;
-	enum tb_security_level security_level;
-	unsigned long privdata[0];
-};
-
 static inline void *tb_priv(struct tb *tb)
 {
 	return (void *)tb->privdata;
@@ -368,7 +327,6 @@ static inline int tb_port_write(struct tb_port *port, const void *buffer,
 struct tb *icm_probe(struct tb_nhi *nhi);
 struct tb *tb_probe(struct tb_nhi *nhi);
 
-extern struct bus_type tb_bus_type;
 extern struct device_type tb_domain_type;
 extern struct device_type tb_switch_type;
 
diff --git a/include/linux/thunderbolt.h b/include/linux/thunderbolt.h
index b512b1e2b4f2..910b1bf92112 100644
--- a/include/linux/thunderbolt.h
+++ b/include/linux/thunderbolt.h
@@ -14,7 +14,9 @@
 #ifndef THUNDERBOLT_H_
 #define THUNDERBOLT_H_
 
+#include <linux/device.h>
 #include <linux/list.h>
+#include <linux/mutex.h>
 #include <linux/uuid.h>
 
 enum tb_cfg_pkg_type {
@@ -33,6 +35,49 @@ enum tb_cfg_pkg_type {
 	TB_CFG_PKG_PREPARE_TO_SLEEP = 13,
 };
 
+/**
+ * enum tb_security_level - Thunderbolt security level
+ * @TB_SECURITY_NONE: No security, legacy mode
+ * @TB_SECURITY_USER: User approval required at minimum
+ * @TB_SECURITY_SECURE: One time saved key required at minimum
+ * @TB_SECURITY_DPONLY: Only tunnel Display port (and USB)
+ */
+enum tb_security_level {
+	TB_SECURITY_NONE,
+	TB_SECURITY_USER,
+	TB_SECURITY_SECURE,
+	TB_SECURITY_DPONLY,
+};
+
+/**
+ * struct tb - main thunderbolt bus structure
+ * @dev: Domain device
+ * @lock: Big lock. Must be held when accessing any struct
+ *	  tb_switch / struct tb_port.
+ * @nhi: Pointer to the NHI structure
+ * @ctl: Control channel for this domain
+ * @wq: Ordered workqueue for all domain specific work
+ * @root_switch: Root switch of this domain
+ * @cm_ops: Connection manager specific operations vector
+ * @index: Linux assigned domain number
+ * @security_level: Current security level
+ * @privdata: Private connection manager specific data
+ */
+struct tb {
+	struct device dev;
+	struct mutex lock;
+	struct tb_nhi *nhi;
+	struct tb_ctl *ctl;
+	struct workqueue_struct *wq;
+	struct tb_switch *root_switch;
+	const struct tb_cm_ops *cm_ops;
+	int index;
+	enum tb_security_level security_level;
+	unsigned long privdata[0];
+};
+
+extern struct bus_type tb_bus_type;
+
 /**
  * struct tb_property_dir - XDomain property directory
  * @uuid: Directory UUID or %NULL if root directory
-- 
2.14.1
