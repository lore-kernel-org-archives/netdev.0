From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,1/2] hv_netvsc: Remove unnecessary var link_state from struct netvsc_device_info
Date: Wed, 21 Jun 2017 16:40:46 -0700
Message-ID: <1498088447-27282-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

We simply use rndis_device->link_state in the netdev_dbg. The variable,
link_state from struct netvsc_device_info, is not used anywhere else.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    5 +++--
 drivers/net/hyperv/rndis_filter.c |    4 +---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index b30a3c2..ced947d 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -146,7 +146,6 @@ struct hv_netvsc_packet {
 
 struct netvsc_device_info {
 	unsigned char mac_adr[ETH_ALEN];
-	bool link_state;	/* 0 - link up, 1 - link down */
 	int  ring_size;
 	u32  max_num_vrss_chns;
 	u32  num_chn;
@@ -165,7 +164,7 @@ struct rndis_device {
 	struct net_device *ndev;
 
 	enum rndis_device_state state;
-	bool link_state;
+
 	atomic_t new_req_id;
 
 	spinlock_t request_lock;
@@ -173,6 +172,8 @@ struct rndis_device {
 
 	struct work_struct mcast_work;
 
+	bool link_state;        /* 0 - link up, 1 - link down */
+
 	u8 hw_mac_adr[ETH_ALEN];
 	u8 rss_key[NETVSC_HASH_KEYLEN];
 	u16 ind_table[ITAB_NUM];
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index cb79cd0..85c00e1 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1185,11 +1185,9 @@ int rndis_filter_device_add(struct hv_device *dev,
 
 	rndis_filter_query_device_link_status(rndis_device);
 
-	device_info->link_state = rndis_device->link_state;
-
 	netdev_dbg(net, "Device MAC %pM link state %s\n",
 		   rndis_device->hw_mac_adr,
-		   device_info->link_state ? "down" : "up");
+		   rndis_device->link_state ? "down" : "up");
 
 	if (net_device->nvsp_version < NVSP_PROTOCOL_VERSION_5)
 		return 0;
-- 
1.7.1
