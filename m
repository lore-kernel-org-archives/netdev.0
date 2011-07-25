From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: Convert struct net_device uc_promisc to bool
Date: Mon, 25 Jul 2011 07:41:26 -0700
Message-ID: <813214b21d4db8d08a76c648ea1d3286b441b706.1311604594.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4259 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431Ab1GYOl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jul 2011 10:41:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to use int, its uses are boolean.
May save a few bytes one day.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 34f3abc..1d92acc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1132,7 +1132,7 @@ struct net_device {
 	spinlock_t		addr_list_lock;
 	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
 	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
-	int			uc_promisc;
+	bool			uc_promisc;
 	unsigned int		promiscuity;
 	unsigned int		allmulti;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 9444c5c..17d67b5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4497,10 +4497,10 @@ void __dev_set_rx_mode(struct net_device *dev)
 		 */
 		if (!netdev_uc_empty(dev) && !dev->uc_promisc) {
 			__dev_set_promiscuity(dev, 1);
-			dev->uc_promisc = 1;
+			dev->uc_promisc = true;
 		} else if (netdev_uc_empty(dev) && dev->uc_promisc) {
 			__dev_set_promiscuity(dev, -1);
-			dev->uc_promisc = 0;
+			dev->uc_promisc = false;
 		}
 
 		if (ops->ndo_set_multicast_list)
-- 
1.7.6.131.g99019

