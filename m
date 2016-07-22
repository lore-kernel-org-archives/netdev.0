From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 4/9] staging: slicoss: start tx queue when interface is brought up
Date: Fri, 22 Jul 2016 23:09:14 +0200
Message-ID: <1469221759-17652-5-git-send-email-LinoSanfilippo@gmx.de>
References: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: liodot@gmail.com, charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no reason to delay tx queue activation until a link is detected.
So start the queue when the interface is brought up and stop it when the
interface is brought down.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slicoss.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 4dba080..577c2d2 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -1028,7 +1028,6 @@ static void slic_link_upr_complete(struct adapter *adapter, u32 isr)
 		/* setup the mac */
 		slic_config_set(adapter, true);
 		adapter->linkstate = LINK_UP;
-		netif_start_queue(adapter->netdev);
 		netif_carrier_on(adapter->netdev);
 	}
 }
@@ -2419,7 +2418,6 @@ static int slic_entry_open(struct net_device *dev)
 	unsigned long flags;
 	int status;
 
-	netif_stop_queue(adapter->netdev);
 	netif_carrier_off(dev);
 
 	spin_lock_irqsave(&slic_global.driver_lock, flags);
@@ -2443,6 +2441,9 @@ static int slic_entry_open(struct net_device *dev)
 
 spin_unlock:
 	spin_unlock_irqrestore(&slic_global.driver_lock, flags);
+
+	netif_start_queue(adapter->netdev);
+
 	return status;
 }
 
-- 
1.9.1
