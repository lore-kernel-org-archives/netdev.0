From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] amd8111e: use net_device_stats from struct
 net_device
Date: Fri, 20 Aug 2010 15:08:23 +0200
Message-ID: <1282309703.2484.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48356 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab0HTNI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 09:08:28 -0400
Received: by wwi17 with SMTP id 17so4055396wwi.1
        for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 06:08:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in the amd8111e_priv struct.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/amd8111e.c |   14 +++++++-------
 drivers/net/amd8111e.h |    1 -
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 1f5fc64..58a0ab4 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -903,18 +903,18 @@ static int amd8111e_read_mib(void __iomem *mmio, u8 MIB_COUNTER)
 }
 
 /*
-This function reads the mib registers and returns the hardware statistics. It  updates previous internal driver statistics with new values.
-*/
-static struct net_device_stats *amd8111e_get_stats(struct net_device * dev)
+ * This function reads the mib registers and returns the hardware statistics.
+ * It updates previous internal driver statistics with new values.
+ */
+static struct net_device_stats *amd8111e_get_stats(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	void __iomem *mmio = lp->mmio;
 	unsigned long flags;
-	/* struct net_device_stats *prev_stats = &lp->prev_stats; */
-	struct net_device_stats* new_stats = &lp->stats;
+	struct net_device_stats *new_stats = &dev->stats;
 
-	if(!lp->opened)
-		return &lp->stats;
+	if (!lp->opened)
+		return new_stats;
 	spin_lock_irqsave (&lp->lock, flags);
 
 	/* stats.rx_packets */
diff --git a/drivers/net/amd8111e.h b/drivers/net/amd8111e.h
index ac36eb6..b5926af 100644
--- a/drivers/net/amd8111e.h
+++ b/drivers/net/amd8111e.h
@@ -787,7 +787,6 @@ struct amd8111e_priv{
 	struct vlan_group		*vlgrp;
 #endif
 	char opened;
-	struct net_device_stats stats;
 	unsigned int drv_rx_errors;
 	struct amd8111e_coalesce_conf coal_conf;
 


