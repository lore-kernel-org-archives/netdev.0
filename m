From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next, 3/4] hv_netvsc: Simplify the limit check in netvsc_set_channels()
Date: Fri,  1 Sep 2017 14:30:06 -0700
Message-ID: <20170901213007.10325-4-haiyangz@exchange.microsoft.com>
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

Because of the following code, net->num_tx_queues equals to
VRSS_CHANNEL_MAX, and max_chn is less than or equals to VRSS_CHANNEL_MAX.

netvsc_drv.c:
alloc_etherdev_mq(sizeof(struct net_device_context),
                                VRSS_CHANNEL_MAX);
rndis_filter.c:
net_device->max_chn = min_t(u32, VRSS_CHANNEL_MAX, num_possible_rss_qs);

So this patch removes the unnecessary limit check before comparing
with "max_chn".

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index b8e23e257f00..718d126108f6 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -830,9 +830,6 @@ static int netvsc_set_channels(struct net_device *net,
 	    channels->rx_count || channels->tx_count || channels->other_count)
 		return -EINVAL;
 
-	if (count > net->num_tx_queues || count > VRSS_CHANNEL_MAX)
-		return -EINVAL;
-
 	if (!nvdev || nvdev->destroy)
 		return -ENODEV;
 
-- 
2.14.1
