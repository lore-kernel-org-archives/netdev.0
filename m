From: Ivan Mikhaylov <ivan@de.ibm.com>
Subject: [PATCH 2/2] net/ibm/emac: add mutex to 'set multicast list'
Date: Wed, 14 Sep 2016 19:06:45 +0300
Message-ID: <1473869205-85314-2-git-send-email-ivan@de.ibm.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

for preventing race conditions within ioctl calls.

Signed-off-by: Ivan Mikhaylov <ivan@de.ibm.com>
---
 drivers/net/ethernet/ibm/emac/core.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 2dfc603..7af09cb 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -977,7 +977,10 @@ static void emac_set_multicast_list(struct net_device *ndev)
 		dev->mcast_pending = 1;
 		return;
 	}
+
+	mutex_lock(&dev->link_lock);
 	__emac_set_multicast_list(dev);
+	mutex_unlock(&dev->link_lock);
 }
 
 static int emac_set_mac_address(struct net_device *ndev, void *sa)
-- 
2.7.4 (Apple Git-66)
