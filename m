From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/42] atm: lec: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:32:59 -0700 (PDT)
Message-ID: <20110417.173259.115936830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753701Ab1DRAde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:34 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 73B8524C089
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'eth' is set but unused in lec_handle_bridge().  Also,
the variable 'priv' is set but unused in lane_module_cleanup().

Just kill them off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/atm/lec.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 38754fd..25073b6 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -129,7 +129,6 @@ static struct net_device *dev_lec[MAX_LEC_ITF];
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ethhdr *eth;
 	char *buff;
 	struct lec_priv *priv;
 
@@ -138,7 +137,6 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 	 * LE_TOPOLOGY_REQUEST with the same value of Topology Change bit
 	 * as the Config BPDU has
 	 */
-	eth = (struct ethhdr *)skb->data;
 	buff = skb->data + skb->dev->hard_header_len;
 	if (*buff++ == 0x42 && *buff++ == 0x42 && *buff++ == 0x03) {
 		struct sock *sk;
@@ -1180,7 +1178,6 @@ static int __init lane_module_init(void)
 static void __exit lane_module_cleanup(void)
 {
 	int i;
-	struct lec_priv *priv;
 
 	remove_proc_entry("lec", atm_proc_root);
 
@@ -1188,7 +1185,6 @@ static void __exit lane_module_cleanup(void)
 
 	for (i = 0; i < MAX_LEC_ITF; i++) {
 		if (dev_lec[i] != NULL) {
-			priv = netdev_priv(dev_lec[i]);
 			unregister_netdev(dev_lec[i]);
 			free_netdev(dev_lec[i]);
 			dev_lec[i] = NULL;
-- 
1.7.4.3

