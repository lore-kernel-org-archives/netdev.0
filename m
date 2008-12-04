From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next] xtensa: Kill directly reference of netdev->priv
Date: Thu, 04 Dec 2008 20:56:38 +0800
Message-ID: <4937D386.7070108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52753 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756600AbYLDM4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 07:56:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Not do compile test, because no such arch.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 arch/xtensa/platforms/iss/network.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
index 87f47ca..64f057d 100644
--- a/arch/xtensa/platforms/iss/network.c
+++ b/arch/xtensa/platforms/iss/network.c
@@ -365,7 +365,7 @@ static int tuntap_probe(struct iss_net_private *lp, int index, char *init)
 
 static int iss_net_rx(struct net_device *dev)
 {
-	struct iss_net_private *lp = dev->priv;
+	struct iss_net_private *lp = netdev_priv(dev);
 	int pkt_len;
 	struct sk_buff *skb;
 
@@ -456,7 +456,7 @@ static void iss_net_timer(unsigned long priv)
 
 static int iss_net_open(struct net_device *dev)
 {
-	struct iss_net_private *lp = dev->priv;
+	struct iss_net_private *lp = netdev_priv(dev);
 	char addr[sizeof "255.255.255.255\0"];
 	int err;
 
@@ -496,7 +496,7 @@ out:
 
 static int iss_net_close(struct net_device *dev)
 {
-	struct iss_net_private *lp = dev->priv;
+	struct iss_net_private *lp = netdev_priv(dev);
 printk("iss_net_close!\n");
 	netif_stop_queue(dev);
 	spin_lock(&lp->lock);
@@ -515,7 +515,7 @@ printk("iss_net_close!\n");
 
 static int iss_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct iss_net_private *lp = dev->priv;
+	struct iss_net_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int len;
 
@@ -551,7 +551,7 @@ static int iss_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *iss_net_get_stats(struct net_device *dev)
 {
-	struct iss_net_private *lp = dev->priv;
+	struct iss_net_private *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -578,7 +578,7 @@ static void iss_net_tx_timeout(struct net_device *dev)
 static int iss_net_set_mac(struct net_device *dev, void *addr)
 {
 #if 0
-	struct iss_net_private *lp = dev->priv;
+	struct iss_net_private *lp = netdev_priv(dev);
 	struct sockaddr *hwaddr = addr;
 
 	spin_lock(&lp->lock);
@@ -592,7 +592,7 @@ static int iss_net_set_mac(struct net_device *dev, void *addr)
 static int iss_net_change_mtu(struct net_device *dev, int new_mtu)
 {
 #if 0
-	struct iss_net_private *lp = dev->priv;
+	struct iss_net_private *lp = netdev_priv(dev);
 	int err = 0;
 
 	spin_lock(&lp->lock);
@@ -636,7 +636,7 @@ static int iss_net_configure(int index, char *init)
 
 	/* Initialize private element. */
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	*lp = ((struct iss_net_private) {
 		.device_list		= LIST_HEAD_INIT(lp->device_list),
 		.opened_list		= LIST_HEAD_INIT(lp->opened_list),
-- 
1.5.3.4


