From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/4] e1000: sparse warnings fixes
Date: Mon, 29 Oct 2007 10:46:19 -0700
Message-ID: <20071029174619.25245.12005.stgit@localhost.localdomain>
References: <20071029174605.25245.15294.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55483 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754467AbXJ2Rre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 13:47:34 -0400
In-Reply-To: <20071029174605.25245.15294.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Fix sparse warnings and problems from e1000 driver.

Added a sparse fix for the module param array index
-- Auke

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |    8 ++++++++
 drivers/net/e1000/e1000_ethtool.c |   29 ++++++++++++-----------------
 drivers/net/e1000/e1000_hw.c      |    4 ++--
 drivers/net/e1000/e1000_main.c    |    7 ++-----
 drivers/net/e1000/e1000_param.c   |   23 ++++++++++++-----------
 5 files changed, 36 insertions(+), 35 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 781ed99..3b84028 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -351,4 +351,12 @@ enum e1000_state_t {
 	__E1000_DOWN
 };
 
+extern char e1000_driver_name[];
+extern const char e1000_driver_version[];
+
+extern void e1000_power_up_phy(struct e1000_adapter *);
+extern void e1000_set_ethtool_ops(struct net_device *netdev);
+extern void e1000_check_options(struct e1000_adapter *adapter);
+
+
 #endif /* _E1000_H_ */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 6c9a643..667f18b 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -32,9 +32,6 @@
 
 #include <asm/uaccess.h>
 
-extern char e1000_driver_name[];
-extern char e1000_driver_version[];
-
 extern int e1000_up(struct e1000_adapter *adapter);
 extern void e1000_down(struct e1000_adapter *adapter);
 extern void e1000_reinit_locked(struct e1000_adapter *adapter);
@@ -733,16 +730,16 @@ err_setup:
 
 #define REG_PATTERN_TEST(R, M, W)                                              \
 {                                                                              \
-	uint32_t pat, value;                                                   \
-	uint32_t test[] =                                                      \
+	uint32_t pat, val;                                                     \
+	const uint32_t test[] = 					       \
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};              \
-	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {              \
+	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {           	       \
 		E1000_WRITE_REG(&adapter->hw, R, (test[pat] & W));             \
-		value = E1000_READ_REG(&adapter->hw, R);                       \
-		if (value != (test[pat] & W & M)) {                             \
+		val = E1000_READ_REG(&adapter->hw, R);                         \
+		if (val != (test[pat] & W & M)) {                              \
 			DPRINTK(DRV, ERR, "pattern test reg %04X failed: got " \
 			        "0x%08X expected 0x%08X\n",                    \
-			        E1000_##R, value, (test[pat] & W & M));        \
+			        E1000_##R, val, (test[pat] & W & M));          \
 			*data = (adapter->hw.mac_type < e1000_82543) ?         \
 				E1000_82542_##R : E1000_##R;                   \
 			return 1;                                              \
@@ -752,12 +749,12 @@ err_setup:
 
 #define REG_SET_AND_CHECK(R, M, W)                                             \
 {                                                                              \
-	uint32_t value;                                                        \
+	uint32_t val;                                                          \
 	E1000_WRITE_REG(&adapter->hw, R, W & M);                               \
-	value = E1000_READ_REG(&adapter->hw, R);                               \
-	if ((W & M) != (value & M)) {                                          \
+	val = E1000_READ_REG(&adapter->hw, R);                                 \
+	if ((W & M) != (val & M)) {                                            \
 		DPRINTK(DRV, ERR, "set/check reg %04X test failed: got 0x%08X "\
-		        "expected 0x%08X\n", E1000_##R, (value & M), (W & M)); \
+		        "expected 0x%08X\n", E1000_##R, (val & M), (W & M));   \
 		*data = (adapter->hw.mac_type < e1000_82543) ?                 \
 			E1000_82542_##R : E1000_##R;                           \
 		return 1;                                                      \
@@ -1621,8 +1618,6 @@ e1000_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
-extern void e1000_power_up_phy(struct e1000_adapter *);
-
 static void
 e1000_diag_test(struct net_device *netdev,
 		   struct ethtool_test *eth_test, uint64_t *data)
@@ -1859,8 +1854,8 @@ e1000_phys_id(struct net_device *netdev, uint32_t data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
-		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
+	if (!data)
+		data = INT_MAX;
 
 	if (adapter->hw.mac_type < e1000_82571) {
 		if (!adapter->blink_timer.function) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 8fa0fe4..7c6888c 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -8607,7 +8607,7 @@ e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
 
     DEBUGFUNC("e1000_read_ich8_data");
 
-    if (size < 1  || size > 2 || data == 0x0 ||
+    if (size < 1  || size > 2 || data == NULL ||
         index > ICH_FLASH_LINEAR_ADDR_MASK)
         return error;
 
@@ -8841,7 +8841,7 @@ e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data)
  * amount of NVM used in each bank is a *minimum* of 4 KBytes, but in fact the
  * bank size may be 4, 8 or 64 KBytes
  *****************************************************************************/
-int32_t
+static int32_t
 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank)
 {
     union ich8_hws_flash_status hsfsts;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f1ce348..72deff0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -37,8 +37,8 @@ static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
 #define DRIVERNAPI "-NAPI"
 #endif
 #define DRV_VERSION "7.3.20-k2"DRIVERNAPI
-char e1000_driver_version[] = DRV_VERSION;
-static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
+const char e1000_driver_version[] = DRV_VERSION;
+static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
  *
@@ -188,7 +188,6 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			   int cmd);
-void e1000_set_ethtool_ops(struct net_device *netdev);
 static void e1000_enter_82542_rst(struct e1000_adapter *adapter);
 static void e1000_leave_82542_rst(struct e1000_adapter *adapter);
 static void e1000_tx_timeout(struct net_device *dev);
@@ -213,8 +212,6 @@ static void e1000_shutdown(struct pci_dev *pdev);
 static void e1000_netpoll (struct net_device *netdev);
 #endif
 
-extern void e1000_check_options(struct e1000_adapter *adapter);
-
 #define COPYBREAK_DEFAULT 256
 static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
 module_param(copybreak, uint, 0644);
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index f485874..e6565ce 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -46,7 +46,7 @@
 #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
 #define E1000_PARAM(X, desc) \
 	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
-	static int num_##X = 0; \
+	static unsigned int num_##X; \
 	module_param_array_named(X, X, int, &num_##X, 0); \
 	MODULE_PARM_DESC(X, desc);
 
@@ -198,9 +198,9 @@ E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
 
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
-	char *name;
-	char *err;
-	int  def;
+	const char *name;
+	const char *err;
+	int def;
 	union {
 		struct { /* range_option info */
 			int min;
@@ -214,8 +214,9 @@ struct e1000_option {
 };
 
 static int __devinit
-e1000_validate_option(int *value, struct e1000_option *opt,
-		struct e1000_adapter *adapter)
+e1000_validate_option(unsigned int *value,
+		      const struct e1000_option *opt,
+		      struct e1000_adapter *adapter)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -348,7 +349,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_XsumRX > bd) {
-			int rx_csum = XsumRX[bd];
+			unsigned int rx_csum = XsumRX[bd];
 			e1000_validate_option(&rx_csum, &opt, adapter);
 			adapter->rx_csum = rx_csum;
 		} else {
@@ -374,7 +375,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_FlowControl > bd) {
-			int fc = FlowControl[bd];
+			unsigned int fc = FlowControl[bd];
 			e1000_validate_option(&fc, &opt, adapter);
 			adapter->hw.fc = adapter->hw.original_fc = fc;
 		} else {
@@ -506,7 +507,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_SmartPowerDownEnable > bd) {
-			int spd = SmartPowerDownEnable[bd];
+			unsigned int spd = SmartPowerDownEnable[bd];
 			e1000_validate_option(&spd, &opt, adapter);
 			adapter->smart_power_down = spd;
 		} else {
@@ -522,7 +523,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 
 		if (num_KumeranLockLoss > bd) {
-			int kmrn_lock_loss = KumeranLockLoss[bd];
+			unsigned int kmrn_lock_loss = KumeranLockLoss[bd];
 			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
 			adapter->hw.kmrn_lock_loss_workaround_disabled = !kmrn_lock_loss;
 		} else {
@@ -581,7 +582,7 @@ e1000_check_fiber_options(struct e1000_adapter *adapter)
 static void __devinit
 e1000_check_copper_options(struct e1000_adapter *adapter)
 {
-	int speed, dplx, an;
+	unsigned int speed, dplx, an;
 	int bd = adapter->bd_number;
 
 	{ /* Speed */
