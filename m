From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6] qlcnic: Fix Compilation Issue when CONFIG_INET
 was not set
Date: Thu, 3 Jun 2010 10:50:56 -0700
Message-ID: <alpine.OSX.2.00.1006031034500.48386@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>
To: <linux-next@vger.kernel.org>, netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please apply.

thanks,
Anirban

Original code was placed incorrectly inside a block of code marked
with CONFIG_INET directive. Fix by moving it outside.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   81 +++++++++++++++++++-------------------
 1 files changed, 40 insertions(+), 41 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 119bcae..99371bc 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2581,6 +2581,46 @@ reschedule:
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 }
 
+static int
+qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
+{
+	int err;
+
+	err = qlcnic_can_start_firmware(adapter);
+	if (err)
+		return err;
+
+	qlcnic_check_options(adapter);
+
+	adapter->need_fw_reset = 0;
+
+	return err;
+}
+
+static int
+qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+{
+	return -EOPNOTSUPP;
+}
+
+static int
+qlcnicvf_set_ilb_mode(struct qlcnic_adapter *adapter)
+{
+	return -EOPNOTSUPP;
+}
+
+static void
+qlcnicvf_clear_ilb_mode(struct qlcnic_adapter *adapter)
+{
+	return;
+}
+
 static ssize_t
 qlcnic_store_bridged_mode(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
@@ -2954,47 +2994,6 @@ done:
 	return NOTIFY_DONE;
 }
 
-static int
-qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
-{
-	int err;
-
-	err = qlcnic_can_start_firmware(adapter);
-	if (err)
-		return err;
-
-	qlcnic_check_options(adapter);
-
-	adapter->need_fw_reset = 0;
-
-	return err;
-}
-
-static int
-qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
-{
-	return -EOPNOTSUPP;
-}
-
-static int
-qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
-{
-	return -EOPNOTSUPP;
-}
-
-static int
-qlcnicvf_set_ilb_mode(struct qlcnic_adapter *adapter)
-{
-	return -EOPNOTSUPP;
-}
-
-static void
-qlcnicvf_clear_ilb_mode(struct qlcnic_adapter *adapter)
-{
-	return;
-}
-
-
 static struct notifier_block	qlcnic_netdev_cb = {
 	.notifier_call = qlcnic_netdev_event,
 };
-- 
1.6.0.2
