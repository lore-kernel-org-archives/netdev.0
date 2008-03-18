From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] forcedeth: Use round_jiffies for stats timer
Date: Tue, 18 Mar 2008 11:07:18 +0000 (GMT)
Message-ID: <20080318110718.A0AFE9D4143@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from queueout03-winn.ispmail.ntl.com ([81.103.221.33]:34281 "EHLO
	queueout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751863AbYCRLNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 07:13:54 -0400
Cc: aabdulla@nvidia.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This timer doesn't need to run at precise times, so round it to a whole
second to decrease wakeups.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 drivers/net/forcedeth.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 801b4d9..3f0d242 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3792,7 +3792,8 @@ static void nv_do_stats_poll(unsigned long data)
 	nv_get_hw_stats(dev);
 
 	if (!np->in_shutdown)
-		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
+		mod_timer(&np->stats_poll,
+			round_jiffies(jiffies + STATS_INTERVAL));
 }
 
 static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -4996,7 +4997,8 @@ static int nv_open(struct net_device *dev)
 
 	/* start statistics timer */
 	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2))
-		mod_timer(&np->stats_poll, jiffies + STATS_INTERVAL);
+		mod_timer(&np->stats_poll,
+			round_jiffies(jiffies + STATS_INTERVAL));
 
 	spin_unlock_irq(&np->lock);
 
-- 
1.5.4.4

