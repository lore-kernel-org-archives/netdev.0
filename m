From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next, 1/4] hv_netvsc: Clean up an unused parameter in rndis_filter_set_rss_param()
Date: Fri,  1 Sep 2017 14:30:04 -0700
Message-ID: <20170901213007.10325-2-haiyangz@exchange.microsoft.com>
References: <20170901213007.10325-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901213007.10325-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

This patch removes the parameter, num_queue in
rndis_filter_set_rss_param(), which is no longer in use.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   | 2 +-
 drivers/net/hyperv/netvsc_drv.c   | 2 +-
 drivers/net/hyperv/rndis_filter.c | 5 ++---
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index ff1c0c8d5e0d..ec546da86683 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -213,7 +213,7 @@ void rndis_filter_update(struct netvsc_device *nvdev);
 void rndis_filter_device_remove(struct hv_device *dev,
 				struct netvsc_device *nvdev);
 int rndis_filter_set_rss_param(struct rndis_device *rdev,
-			       const u8 *key, int num_queue);
+			       const u8 *key);
 int rndis_filter_receive(struct net_device *ndev,
 			 struct netvsc_device *net_dev,
 			 struct hv_device *dev,
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 97ed4bdc439f..b8e23e257f00 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1424,7 +1424,7 @@ static int netvsc_set_rxfh(struct net_device *dev, const u32 *indir,
 		key = rndis_dev->rss_key;
 	}
 
-	return rndis_filter_set_rss_param(rndis_dev, key, ndev->num_chn);
+	return rndis_filter_set_rss_param(rndis_dev, key);
 }
 
 /* Hyper-V RNDIS protocol does not have ring in the HW sense.
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 36e9ee82ec6f..496fefa7c7c4 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -717,7 +717,7 @@ rndis_filter_set_offload_params(struct net_device *ndev,
 }
 
 int rndis_filter_set_rss_param(struct rndis_device *rdev,
-			       const u8 *rss_key, int num_queue)
+			       const u8 *rss_key)
 {
 	struct net_device *ndev = rdev->ndev;
 	struct rndis_request *request;
@@ -1258,8 +1258,7 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 		   atomic_read(&net_device->open_chn) == net_device->num_chn);
 
 	/* ignore failues from setting rss parameters, still have channels */
-	rndis_filter_set_rss_param(rndis_device, netvsc_hash_key,
-				   net_device->num_chn);
+	rndis_filter_set_rss_param(rndis_device, netvsc_hash_key);
 out:
 	if (ret) {
 		net_device->max_chn = 1;
-- 
2.14.1
