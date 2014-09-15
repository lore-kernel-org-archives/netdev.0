From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] bridge: Fix br_should_learn to check vlan_enabled
Date: Mon, 15 Sep 2014 15:24:26 -0400
Message-ID: <1410809066-4434-1-git-send-email-vyasevic@redhat.com>
Cc: toshiaki.makita1@gmail.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:56372 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185AbaIOTYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:24:45 -0400
Received: by mail-qa0-f42.google.com with SMTP id j7so4472231qaq.15
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 12:24:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As Toshiaki Makita pointed out, the BRIDGE_INPUT_SKB_CB will
not be initialized in br_should_learn() as that function
is called only from br_handle_local_finish().  That is
an input handler for link-local ethernet traffic so it perfectly
correct to check br->vlan_enabled here.

Reported-by: Toshiaki Makita<toshiaki.makita1@gmail.com>
Fixes: 20adfa1 bridge: Check if vlan filtering is enabled only once.
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_vlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 4b86738..3ba57fc 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -280,7 +280,7 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 	struct net_port_vlans *v;
 
 	/* If filtering was disabled at input, let it pass. */
-	if (!BR_INPUT_SKB_CB(skb)->vlan_filtered)
+	if (!br->vlan_enabled)
 		return true;
 
 	v = rcu_dereference(p->vlan_info);
-- 
1.9.3
