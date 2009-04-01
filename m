From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/9] ixgbe: fix build when DEBUG is defined
Date: Wed, 01 Apr 2009 00:32:42 -0700
Message-ID: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:47265
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752391AbZDAHdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:33:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The ixgbe driver had issues when DEBUG was defined because the hw_dbg macro
was incomplete.  This patch completes the code based off of the code that
already existed in the igb module.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.h |    9 +++------
 drivers/net/ixgbe/ixgbe_main.c   |   12 ++++++++++++
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 7e94d6d..24f73e7 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -96,14 +96,11 @@ s32 ixgbe_write_analog_reg8_generic(struct ixgbe_hw *hw, u32 reg, u8 val);
 #define IXGBE_WRITE_FLUSH(a) IXGBE_READ_REG(a, IXGBE_STATUS)
 
 #ifdef DEBUG
+extern char *ixgbe_get_hw_dev_name(struct ixgbe_hw *hw);
 #define hw_dbg(hw, format, arg...) \
-printk(KERN_DEBUG, "%s: " format, ixgbe_get_hw_dev_name(hw), ##arg);
+	printk(KERN_DEBUG "%s: " format, ixgbe_get_hw_dev_name(hw), ##arg)
 #else
-static inline int __attribute__ ((format (printf, 2, 3)))
-hw_dbg(struct ixgbe_hw *hw, const char *format, ...)
-{
-	return 0;
-}
+#define hw_dbg(hw, format, arg...) do {} while (0)
 #endif
 
 #endif /* IXGBE_COMMON */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 79aa811..fd27513 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4987,8 +4987,20 @@ static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
 
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
+
 #endif /* CONFIG_IXGBE_DCA */
+#ifdef DEBUG
+/**
+ * ixgbe_get_hw_dev_name - return device name string
+ * used by hardware layer to print debugging information
+ **/
+char *ixgbe_get_hw_dev_name(struct ixgbe_hw *hw)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+	return adapter->netdev->name;
+}
 
+#endif
 module_exit(ixgbe_exit_module);
 
 /* ixgbe_main.c */

