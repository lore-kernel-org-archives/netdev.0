From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix the list processing for network change event
Date: Thu, 21 Apr 2016 16:13:01 -0700
Message-ID: <1461280381-17530-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	vkuznets@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RNDIS_STATUS_NETWORK_CHANGE event is handled as two "half events" --
media disconnect & connect. The second half should be added to the list
head, not to the tail. So all events are processed in normal order.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index bfdb568a..ba3f3f3 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1125,7 +1125,7 @@ static void netvsc_link_change(struct work_struct *w)
 			netif_tx_stop_all_queues(net);
 			event->event = RNDIS_STATUS_MEDIA_CONNECT;
 			spin_lock_irqsave(&ndev_ctx->lock, flags);
-			list_add_tail(&event->list, &ndev_ctx->reconfig_events);
+			list_add(&event->list, &ndev_ctx->reconfig_events);
 			spin_unlock_irqrestore(&ndev_ctx->lock, flags);
 			reschedule = true;
 		}
-- 
1.7.4.1
