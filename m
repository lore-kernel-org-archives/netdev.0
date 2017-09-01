From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next, 4/4] hv_netvsc: Fix the channel limit in netvsc_set_rxfh()
Date: Fri,  1 Sep 2017 14:30:07 -0700
Message-ID: <20170901213007.10325-5-haiyangz@exchange.microsoft.com>
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

The limit of setting receive indirection table value should be
the current number of channels, not the VRSS_CHANNEL_MAX.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 718d126108f6..9205235ba21c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1407,7 +1407,7 @@ static int netvsc_set_rxfh(struct net_device *dev, const u32 *indir,
 	rndis_dev = ndev->extension;
 	if (indir) {
 		for (i = 0; i < ITAB_NUM; i++)
-			if (indir[i] >= VRSS_CHANNEL_MAX)
+			if (indir[i] >= ndev->num_chn)
 				return -EINVAL;
 
 		for (i = 0; i < ITAB_NUM; i++)
-- 
2.14.1
