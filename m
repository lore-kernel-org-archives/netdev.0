From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 07/15] netvsc: convert ring_size to unsigned
Date: Wed,  3 May 2017 16:01:09 -0700
Message-ID: <20170503230117.20070-8-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35965 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752304AbdECXB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:28 -0400
Received: by mail-pg0-f48.google.com with SMTP id t7so1950682pgt.3
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:28 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ring size module parameter is unsigned not integer.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h | 5 ++---
 drivers/net/hyperv/netvsc.c     | 2 +-
 drivers/net/hyperv/netvsc_drv.c | 8 ++++----
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 262b2ea576a3..2b4a9b058f6d 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -147,7 +147,7 @@ struct hv_netvsc_packet {
 struct netvsc_device_info {
 	unsigned char mac_adr[ETH_ALEN];
 	bool link_state;	/* 0 - link up, 1 - link down */
-	int  ring_size;
+	u32  ring_size;
 	u32  max_num_vrss_chns;
 	u32  num_chn;
 };
@@ -766,8 +766,7 @@ struct netvsc_device {
 	/* Holds rndis device info */
 	void *extension;
 
-	int ring_size;
-
+	u32 ring_size;
 	u32 max_pkt; /* max number of pkt in one send, e.g. 8 */
 	u32 pkt_align; /* alignment bytes, e.g. 8 */
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index cee8e020ac56..480bd7704b68 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1304,7 +1304,7 @@ int netvsc_device_add(struct hv_device *device,
 		      const struct netvsc_device_info *device_info)
 {
 	int i, ret = 0;
-	int ring_size = device_info->ring_size;
+	u32 ring_size = device_info->ring_size;
 	struct netvsc_device *net_device;
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 3fef45421634..fb743c78f3dc 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -43,8 +43,8 @@
 #define RING_SIZE_MIN 64
 #define LINKCHANGE_INT (2 * HZ)
 
-static int ring_size = 128;
-module_param(ring_size, int, S_IRUGO);
+static unsigned int ring_size = 128;
+module_param(ring_size, uint, 0444);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
 
 static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
@@ -1713,8 +1713,8 @@ static int __init netvsc_drv_init(void)
 
 	if (ring_size < RING_SIZE_MIN) {
 		ring_size = RING_SIZE_MIN;
-		pr_info("Increased ring_size to %d (min allowed)\n",
-			ring_size);
+		pr_notice("Increased ring_size to %u (min allowed)\n",
+			  ring_size);
 	}
 	ret = vmbus_driver_register(&netvsc_drv);
 
-- 
2.11.0
