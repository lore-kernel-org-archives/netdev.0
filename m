From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next,1/2] hyperv: Add a check for ring_size value
Date: Wed, 25 Jul 2012 11:08:41 -0700
Message-ID: <1343239722-21328-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It prevents ring_size being set to a too small value.

Reported-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 8e23c08..8c5a1c4 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -47,7 +47,7 @@ struct net_device_context {
 	struct work_struct work;
 };
 
-
+#define RING_SIZE_MIN 64
 static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
@@ -518,6 +518,11 @@ static void __exit netvsc_drv_exit(void)
 
 static int __init netvsc_drv_init(void)
 {
+	if (ring_size < RING_SIZE_MIN) {
+		ring_size = RING_SIZE_MIN;
+		pr_info("Increased ring_size to %d (min allowed)\n",
+			ring_size);
+	}
 	return vmbus_driver_register(&netvsc_drv);
 }
 
-- 
1.7.4.1
