From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] parisc: led: Use for_each_netdev_rcu()
Date: Tue, 10 Nov 2009 05:07:28 +0100
Message-ID: <4AF8E700.9080307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53812 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbZKJEH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 23:07:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use for_each_netdev_rcu() and dont lock dev_base_lock anymore

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/parisc/led.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/parisc/led.c b/drivers/parisc/led.c
index 9581d36..79caf1c 100644
--- a/drivers/parisc/led.c
+++ b/drivers/parisc/led.c
@@ -352,11 +352,9 @@ static __inline__ int led_get_net_activity(void)
 
 	rx_total = tx_total = 0;
 	
-	/* we are running as a workqueue task, so locking dev_base 
-	 * for reading should be OK */
-	read_lock(&dev_base_lock);
+	/* we are running as a workqueue task, so we can use an RCU lookup */
 	rcu_read_lock();
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev_rcu(&init_net, dev) {
 	    const struct net_device_stats *stats;
 	    struct in_device *in_dev = __in_dev_get_rcu(dev);
 	    if (!in_dev || !in_dev->ifa_list)
@@ -368,7 +366,6 @@ static __inline__ int led_get_net_activity(void)
 	    tx_total += stats->tx_packets;
 	}
 	rcu_read_unlock();
-	read_unlock(&dev_base_lock);
 
 	retval = 0;
 
