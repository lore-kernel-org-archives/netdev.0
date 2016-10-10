From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 1/3] openvswitch: vlan: remove wrong likely statement
Date: Mon, 10 Oct 2016 17:02:42 +0200
Message-ID: <a4b63fa787569359d227beecbdbf9b023081cffc.1476111550.git.jbenc@redhat.com>
References: <cover.1476111550.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54886 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753003AbcJJPDE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 11:03:04 -0400
In-Reply-To: <cover.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is called whenever flow key is being extracted from the packet.
The packet may be as likely vlan tagged as not.

Fixes: 018c1dda5ff1 ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/openvswitch/flow.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index c8c82e109c68..22087062bd10 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -343,7 +343,7 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 	key->eth.cvlan.tci = 0;
 	key->eth.cvlan.tpid = 0;
 
-	if (likely(skb_vlan_tag_present(skb))) {
+	if (skb_vlan_tag_present(skb)) {
 		key->eth.vlan.tci = htons(skb->vlan_tci);
 		key->eth.vlan.tpid = skb->vlan_proto;
 	} else {
-- 
1.8.3.1
