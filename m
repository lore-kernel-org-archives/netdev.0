From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v3 net-next 01/10] openvswitch: Fix comments for skb->_nfct
Date: Wed,  8 Feb 2017 17:30:28 -0800
Message-ID: <1486603837-7202-2-git-send-email-jarno@ovn.org>
References: <1486603837-7202-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, joe@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:36483 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752508AbdBIBbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 20:31:02 -0500
In-Reply-To: <1486603837-7202-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix comments referring to skb 'nfct' and 'nfctinfo' fields now that
they are combined into '_nfct'.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index fbffe0e..5de6d12 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -157,7 +157,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 	ovs_ct_get_labels(ct, &key->ct.labels);
 }
 
-/* Update 'key' based on skb->nfct.  If 'post_ct' is true, then OVS has
+/* Update 'key' based on skb->_nfct.  If 'post_ct' is true, then OVS has
  * previously sent the packet to conntrack via the ct action.  If
  * 'keep_nat_flags' is true, the existing NAT flags retained, else they are
  * initialized from the connection status.
@@ -421,12 +421,12 @@ ovs_ct_get_info(const struct nf_conntrack_tuple_hash *h)
 
 /* Find an existing connection which this packet belongs to without
  * re-attributing statistics or modifying the connection state.  This allows an
- * skb->nfct lost due to an upcall to be recovered during actions execution.
+ * skb->_nfct lost due to an upcall to be recovered during actions execution.
  *
  * Must be called with rcu_read_lock.
  *
- * On success, populates skb->nfct and skb->nfctinfo, and returns the
- * connection.  Returns NULL if there is no existing entry.
+ * On success, populates skb->_nfct and returns the connection.  Returns NULL
+ * if there is no existing entry.
  */
 static struct nf_conn *
 ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
@@ -464,7 +464,7 @@ ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
 	return ct;
 }
 
-/* Determine whether skb->nfct is equal to the result of conntrack lookup. */
+/* Determine whether skb->_nfct is equal to the result of conntrack lookup. */
 static bool skb_nfct_cached(struct net *net,
 			    const struct sw_flow_key *key,
 			    const struct ovs_conntrack_info *info,
@@ -475,7 +475,7 @@ static bool skb_nfct_cached(struct net *net,
 
 	ct = nf_ct_get(skb, &ctinfo);
 	/* If no ct, check if we have evidence that an existing conntrack entry
-	 * might be found for this skb.  This happens when we lose a skb->nfct
+	 * might be found for this skb.  This happens when we lose a skb->_nfct
 	 * due to an upcall.  If the connection was not confirmed, it is not
 	 * cached and needs to be run through conntrack again.
 	 */
@@ -699,7 +699,7 @@ static int ovs_ct_nat(struct net *net, struct sw_flow_key *key,
 /* Pass 'skb' through conntrack in 'net', using zone configured in 'info', if
  * not done already.  Update key with new CT state after passing the packet
  * through conntrack.
- * Note that if the packet is deemed invalid by conntrack, skb->nfct will be
+ * Note that if the packet is deemed invalid by conntrack, skb->_nfct will be
  * set to NULL and 0 will be returned.
  */
 static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
-- 
2.1.4
