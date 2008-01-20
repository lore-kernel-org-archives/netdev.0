From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 06/18]: Kill useless check
Date: Sun, 20 Jan 2008 18:11:25 +0100 (MET)
Message-ID: <20080120171125.7980.42474.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62347 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452AbYATRL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:26 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Kill useless check

vlan->real_dev is always equal to the device since thats what we used
for the lookup. It doesn't even seem worth a WARN_ON or BUG_ON.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 99c94d927602635ca0994a99bf75edc0d2f80871
tree b7455cbbe55a60f0d13a3b9b64694099e718e6d9
parent aa7c9ed461cf1cf1977a7d5735d464a7539d2518
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:55 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:55 +0100

 net/8021q/vlan_dev.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 51ce421..50d8edc 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -181,24 +181,6 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	/* Take off the VLAN header (4 bytes currently) */
 	skb_pull_rcsum(skb, VLAN_HLEN);
 
-	/* Ok, lets check to make sure the device (dev) we
-	 * came in on is what this VLAN is attached to.
-	 */
-
-	if (dev != VLAN_DEV_INFO(skb->dev)->real_dev) {
-		rcu_read_unlock();
-
-#ifdef VLAN_DEBUG
-		printk(VLAN_DBG "%s: dropping skb: %p because came in on wrong device, dev: %s  real_dev: %s, skb_dev: %s\n",
-			__FUNCTION__, skb, dev->name,
-			VLAN_DEV_INFO(skb->dev)->real_dev->name,
-			skb->dev->name);
-#endif
-		kfree_skb(skb);
-		stats->rx_errors++;
-		return -1;
-	}
-
 	/*
 	 * Deal with ingress priority mapping.
 	 */
