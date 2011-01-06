From: Ferenc Wagner <wferi@niif.hu>
Subject: [PATCH 1/2] netconsole: don't announce stopping if nothing happened
Date: Thu,  6 Jan 2011 16:11:19 +0100
Message-ID: <2a5a11931f2c5e876f2bdb976ec1febd2163c727.1294326001.git.wferi@niif.hu>
References: <cover.1294326001.git.wferi@niif.hu>
Cc: Ferenc Wagner <wferi@niif.hu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs22.lvs.iif.hu ([193.225.14.172]:51319 "EHLO rs22.lvs.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab1AFPsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 10:48:00 -0500
In-Reply-To: <cover.1294326001.git.wferi@niif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ferenc Wagner <wferi@niif.hu>
---
 drivers/net/netconsole.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 94255f0..b2ad998 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -664,6 +664,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	unsigned long flags;
 	struct netconsole_target *nt;
 	struct net_device *dev = ptr;
+	bool stopped = false;
 
 	if (!(event == NETDEV_CHANGENAME || event == NETDEV_UNREGISTER ||
 	      event == NETDEV_BONDING_DESLAVE || event == NETDEV_GOING_DOWN))
@@ -690,13 +691,14 @@ static int netconsole_netdev_event(struct notifier_block *this,
 			case NETDEV_GOING_DOWN:
 			case NETDEV_BONDING_DESLAVE:
 				nt->enabled = 0;
+				stopped = true;
 				break;
 			}
 		}
 		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
-	if (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE)
+	if (stopped && (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE))
 		printk(KERN_INFO "netconsole: network logging stopped, "
 			"interface %s %s\n",  dev->name,
 			event == NETDEV_UNREGISTER ? "unregistered" : "released slaves");
-- 
1.6.5

