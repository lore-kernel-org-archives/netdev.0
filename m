From: sixiao@microsoft.com
Subject: [PATCH net-next,
 1/1] hv_netvsc: call dump_rndis_message() only in netvsc debug mode
Date: Tue, 21 Apr 2015 15:58:05 -0700
Message-ID: <1429657085-23379-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Simon Xiao <sixiao@microsoft.com>
To: kys@microsoft.com, haiyangz@microsoft.com, devel@linuxdriverproject.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Simon Xiao <sixiao@microsoft.com>

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   | 3 +++
 drivers/net/hyperv/netvsc_drv.c   | 8 ++++++++
 drivers/net/hyperv/rndis_filter.c | 3 ++-
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index a10b316..c9be35e 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -28,6 +28,9 @@
 #include <linux/hyperv.h>
 #include <linux/rndis.h>
 
+/* flag for netvsc debug mode */
+extern int debug_mode;
+
 /* RSS related */
 #define OID_GEN_RECEIVE_SCALE_CAPABILITIES 0x00010203  /* query only */
 #define OID_GEN_RECEIVE_SCALE_PARAMETERS 0x00010204  /* query and set */
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a3a9d38..7c41864 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -52,6 +52,10 @@ static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
 
+int debug_mode = 0;
+module_param(debug_mode, int, S_IRUGO);
+MODULE_PARM_DESC(debug_mode, "debug mode: zero(0) for non-debug mode; non-zero for debug mode");
+
 static void do_set_multicast(struct work_struct *w)
 {
 	struct net_device_context *ndevctx =
@@ -999,6 +1003,10 @@ static int __init netvsc_drv_init(void)
 		pr_info("Increased ring_size to %d (min allowed)\n",
 			ring_size);
 	}
+
+	if (debug_mode != 0)
+		pr_info("Run netvsc in debug mode");
+
 	return vmbus_driver_register(&netvsc_drv);
 }
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 0d92efe..a3f43f6 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -429,7 +429,8 @@ int rndis_filter_receive(struct hv_device *dev,
 
 	rndis_msg = pkt->data;
 
-	dump_rndis_message(dev, rndis_msg);
+	if (debug_mode != 0)
+		dump_rndis_message(dev, rndis_msg);
 
 	switch (rndis_msg->ndis_msg_type) {
 	case RNDIS_MSG_PACKET:
-- 
1.8.5.2
