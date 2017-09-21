From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 1/1] net: ti: netcp: use setup_timer
Date: Thu, 21 Sep 2017 18:32:58 +0530
Message-ID: <1505998978-14898-1-git-send-email-allen.lkml@gmail.com>
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 28cb38a..4ad8216 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -3616,9 +3616,8 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	}
 	spin_unlock_bh(&gbe_dev->hw_stats_lock);
 
-	init_timer(&gbe_dev->timer);
-	gbe_dev->timer.data	 = (unsigned long)gbe_dev;
-	gbe_dev->timer.function = netcp_ethss_timer;
+	setup_timer(&gbe_dev->timer, netcp_ethss_timer,
+		    (unsigned long)gbe_dev);
 	gbe_dev->timer.expires	 = jiffies + GBE_TIMER_INTERVAL;
 	add_timer(&gbe_dev->timer);
 	*inst_priv = gbe_dev;
-- 
2.7.4
