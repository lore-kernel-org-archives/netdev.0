From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,1/3] hv_netvsc: Rename ind_table to rx_table
Date: Fri, 13 Oct 2017 12:28:03 -0700
Message-ID: <20171013192805.18183-2-haiyangz@exchange.microsoft.com>
References: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

Rename this variable because it is the Receive indirection
table.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   | 2 +-
 drivers/net/hyperv/netvsc_drv.c   | 4 ++--
 drivers/net/hyperv/rndis_filter.c | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index a81335e8ebe8..65ceb3aec40e 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -179,7 +179,7 @@ struct rndis_device {
 
 	u8 hw_mac_adr[ETH_ALEN];
 	u8 rss_key[NETVSC_HASH_KEYLEN];
-	u16 ind_table[ITAB_NUM];
+	u16 rx_table[ITAB_NUM];
 };
 
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 44746de3dd4c..8fa964e733ad 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1434,7 +1434,7 @@ static int netvsc_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 	rndis_dev = ndev->extension;
 	if (indir) {
 		for (i = 0; i < ITAB_NUM; i++)
-			indir[i] = rndis_dev->ind_table[i];
+			indir[i] = rndis_dev->rx_table[i];
 	}
 
 	if (key)
@@ -1464,7 +1464,7 @@ static int netvsc_set_rxfh(struct net_device *dev, const u32 *indir,
 				return -EINVAL;
 
 		for (i = 0; i < ITAB_NUM; i++)
-			rndis_dev->ind_table[i] = indir[i];
+			rndis_dev->rx_table[i] = indir[i];
 	}
 
 	if (!key) {
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 065b204d8e17..addf9f69c58c 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -759,7 +759,7 @@ int rndis_filter_set_rss_param(struct rndis_device *rdev,
 	/* Set indirection table entries */
 	itab = (u32 *)(rssp + 1);
 	for (i = 0; i < ITAB_NUM; i++)
-		itab[i] = rdev->ind_table[i];
+		itab[i] = rdev->rx_table[i];
 
 	/* Set hask key values */
 	keyp = (u8 *)((unsigned long)rssp + rssp->kashkey_offset);
@@ -1284,8 +1284,8 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 	net_device->num_chn = min(net_device->max_chn, device_info->num_chn);
 
 	for (i = 0; i < ITAB_NUM; i++)
-		rndis_device->ind_table[i] = ethtool_rxfh_indir_default(i,
-							net_device->num_chn);
+		rndis_device->rx_table[i] = ethtool_rxfh_indir_default(
+						i, net_device->num_chn);
 
 	atomic_set(&net_device->open_chn, 1);
 	vmbus_set_sc_create_callback(dev->channel, netvsc_sc_open);
-- 
2.14.1
