From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] myri10ge: Use the instance of
	net_device_stats from net_device.
Date: Wed, 7 Oct 2009 18:15:02 +0530
Message-ID: <20091007124452.GA30109@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:39322 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759077AbZJGMpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 08:45:49 -0400
Received: by fxm27 with SMTP id 27so4552575fxm.17
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 05:45:12 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the private myri10ge_priv structure.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/myri10ge/myri10ge.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 6930c87..29c9fe2 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -207,7 +207,6 @@ struct myri10ge_priv {
 	int big_bytes;
 	int max_intr_slots;
 	struct net_device *dev;
-	struct net_device_stats stats;
 	spinlock_t stats_lock;
 	u8 __iomem *sram;
 	int sram_size;
@@ -1821,7 +1820,7 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	/* force stats update */
 	(void)myri10ge_get_stats(netdev);
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
-		data[i] = ((unsigned long *)&mgp->stats)[i];
+		data[i] = ((unsigned long *)&netdev->stats)[i];
 
 	data[i++] = (unsigned int)mgp->tx_boundary;
 	data[i++] = (unsigned int)mgp->wc_enabled;
@@ -2991,7 +2990,7 @@ static struct net_device_stats *myri10ge_get_stats(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_slice_netstats *slice_stats;
-	struct net_device_stats *stats = &mgp->stats;
+	struct net_device_stats *stats = &dev->stats;
 	int i;
 
 	spin_lock(&mgp->stats_lock);
-- 
1.6.0.4

