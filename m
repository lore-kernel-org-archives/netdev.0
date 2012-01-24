From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH] net/hyperv: fix possible memory leak in do_set_multicast()
Date: Tue, 24 Jan 2012 12:21:28 -0800
Message-ID: <1327436488-24114-1-git-send-email-haiyangz@microsoft.com>
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

do_set_multicast() may not free the memory malloc in
netvsc_set_multicast_list().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc_drv.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 462d05f..1a1ca6c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -68,11 +68,11 @@ static void do_set_multicast(struct work_struct *w)
 
 	nvdev = hv_get_drvdata(ndevctx->device_ctx);
 	if (nvdev == NULL)
-		return;
+		goto out;
 
 	rdev = nvdev->extension;
 	if (rdev == NULL)
-		return;
+		goto out;
 
 	if (net->flags & IFF_PROMISC)
 		rndis_filter_set_packet_filter(rdev,
@@ -83,6 +83,7 @@ static void do_set_multicast(struct work_struct *w)
 			NDIS_PACKET_TYPE_ALL_MULTICAST |
 			NDIS_PACKET_TYPE_DIRECTED);
 
+out:
 	kfree(w);
 }
 
-- 
1.7.4.1
