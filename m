From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next, 2/4] hv_netvsc: Simplify num_chn checking in rndis_filter_device_add()
Date: Fri,  1 Sep 2017 14:30:05 -0700
Message-ID: <20170901213007.10325-3-haiyangz@exchange.microsoft.com>
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

The minus one and assignment to a local variable is not necessary.
This patch simplifies it.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 496fefa7c7c4..69c40b8fccc3 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1067,7 +1067,7 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 	struct ndis_recv_scale_cap rsscap;
 	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
 	unsigned int gso_max_size = GSO_MAX_SIZE;
-	u32 mtu, size, num_rss_qs;
+	u32 mtu, size;
 	const struct cpumask *node_cpu_mask;
 	u32 num_possible_rss_qs;
 	int i, ret;
@@ -1215,8 +1215,8 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 							net_device->num_chn);
 
 	atomic_set(&net_device->open_chn, 1);
-	num_rss_qs = net_device->num_chn - 1;
-	if (num_rss_qs == 0)
+
+	if (net_device->num_chn == 1)
 		return net_device;
 
 	for (i = 1; i < net_device->num_chn; i++) {
-- 
2.14.1
