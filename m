From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 09/16] batman-adv: Update/repair bridge loop avoidance kerneldoc
Date: Wed,  3 Feb 2016 10:18:30 +0800
Message-ID: <1454465917-13332-10-git-send-email-a__13038.9486243532$1454467266$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:28880 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755508AbcBCCkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:40:53 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bridge_loop_avoidance.c | 178 ++++++++++++++++++++++++---------
 1 file changed, 130 insertions(+), 48 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 90c79948979c..131aca049907 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -59,9 +59,11 @@ batadv_bla_send_announce(struct batadv_priv *bat_priv,
 			 struct batadv_bla_backbone_gw *backbone_gw);
 
 /**
- * batadv_choose_claim
+ * batadv_choose_claim - choose the right bucket for a claim.
+ * @data: data to hash
+ * @size: size of the hash table
  *
- * Return: the index of the claim
+ * Return: the hash index of the claim
  */
 static inline u32 batadv_choose_claim(const void *data, u32 size)
 {
@@ -75,9 +77,11 @@ static inline u32 batadv_choose_claim(const void *data, u32 size)
 }
 
 /**
- * batadv_choose_backbone_gw
+ * batadv_choose_backbone_gw - choose the right bucket for a backbone gateway.
+ * @data: data to hash
+ * @size: size of the hash table
  *
- * Return: the index of the backbone gateway
+ * Return: the hash index of the backbone gateway
  */
 static inline u32 batadv_choose_backbone_gw(const void *data, u32 size)
 {
@@ -90,7 +94,13 @@ static inline u32 batadv_choose_backbone_gw(const void *data, u32 size)
 	return hash % size;
 }
 
-/* compares address and vid of two backbone gws */
+/**
+ * batadv_compare_backbone_gw - compare address and vid of two backbone gws
+ * @node: list node of the first entry to compare
+ * @data2: pointer to the second backbone gateway
+ *
+ * Return: 1 if the backbones have the same data, 0 otherwise
+ */
 static int batadv_compare_backbone_gw(const struct hlist_node *node,
 				      const void *data2)
 {
@@ -108,7 +118,13 @@ static int batadv_compare_backbone_gw(const struct hlist_node *node,
 	return 1;
 }
 
-/* compares address and vid of two claims */
+/**
+ * batadv_compare_backbone_gw - compare address and vid of two claims
+ * @node: list node of the first entry to compare
+ * @data2: pointer to the second claims
+ *
+ * Return: 1 if the claim have the same data, 0 otherwise
+ */
 static int batadv_compare_claim(const struct hlist_node *node,
 				const void *data2)
 {
@@ -126,7 +142,10 @@ static int batadv_compare_claim(const struct hlist_node *node,
 	return 1;
 }
 
-/* free a backbone gw */
+/**
+ * batadv_compare_backbone_gw - free backbone gw
+ * @backbone_gw: backbone gateway to be free'd
+ */
 static void
 batadv_backbone_gw_free_ref(struct batadv_bla_backbone_gw *backbone_gw)
 {
@@ -134,14 +153,21 @@ batadv_backbone_gw_free_ref(struct batadv_bla_backbone_gw *backbone_gw)
 		kfree_rcu(backbone_gw, rcu);
 }
 
-/* finally deinitialize the claim */
+/**
+ * batadv_claim_release - release claim from lists and queue for free after rcu
+ *  grace period
+ * @ref: kref pointer of the claim
+ */
 static void batadv_claim_release(struct batadv_bla_claim *claim)
 {
 	batadv_backbone_gw_free_ref(claim->backbone_gw);
 	kfree_rcu(claim, rcu);
 }
 
-/* free a claim, call claim_free_rcu if its the last reference */
+/**
+ * batadv_claim_free_rcu - free a claim
+ * @claim: claim to be free'd
+ */
 static void batadv_claim_free_ref(struct batadv_bla_claim *claim)
 {
 	if (atomic_dec_and_test(&claim->refcount))
@@ -149,12 +175,10 @@ static void batadv_claim_free_ref(struct batadv_bla_claim *claim)
 }
 
 /**
- * batadv_claim_hash_find
+ * batadv_claim_hash_find - looks for a claim in the claim hash
  * @bat_priv: the bat priv with all the soft interface information
  * @data: search data (may be local/static data)
  *
- * looks for a claim in the hash
- *
  * Return: claim if found or NULL otherwise.
  */
 static struct batadv_bla_claim
@@ -190,12 +214,12 @@ static struct batadv_bla_claim
 }
 
 /**
- * batadv_backbone_hash_find - looks for a claim in the hash
+ * batadv_backbone_hash_find - looks for a backbone gateway in the hash
  * @bat_priv: the bat priv with all the soft interface information
  * @addr: the address of the originator
  * @vid: the VLAN ID
  *
- * Return: claim if found or NULL otherwise.
+ * Return: backbone gateway if found or NULL otherwise
  */
 static struct batadv_bla_backbone_gw *
 batadv_backbone_hash_find(struct batadv_priv *bat_priv, u8 *addr,
@@ -233,7 +257,10 @@ batadv_backbone_hash_find(struct batadv_priv *bat_priv, u8 *addr,
 	return backbone_gw_tmp;
 }
 
-/* delete all claims for a backbone */
+/**
+ * batadv_bla_del_backbone_claims - delete all claims for a backbone
+ * @backbone_gw: backbone gateway where the claims should be removed
+ */
 static void
 batadv_bla_del_backbone_claims(struct batadv_bla_backbone_gw *backbone_gw)
 {
@@ -381,14 +408,13 @@ out:
 }
 
 /**
- * batadv_bla_get_backbone_gw
+ * batadv_bla_get_backbone_gw - finds or creates a backbone gateway
  * @bat_priv: the bat priv with all the soft interface information
  * @orig: the mac address of the originator
  * @vid: the VLAN ID
  * @own_backbone: set if the requested backbone is local
  *
- * searches for the backbone gw or creates a new one if it could not
- * be found.
+ * Return: the (possibly created) backbone gateway or NULL on error
  */
 static struct batadv_bla_backbone_gw *
 batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, u8 *orig,
@@ -454,7 +480,13 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, u8 *orig,
 	return entry;
 }
 
-/* update or add the own backbone gw to make sure we announce
+/**
+ * batadv_bla_update_own_backbone_gw - updates the own backbone gw for a VLAN
+ * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: the selected primary interface
+ * @vid: VLAN identifier
+ *
+ * update or add the own backbone gw to make sure we announce
  * where we receive other backbone gws
  */
 static void
@@ -551,12 +583,9 @@ static void batadv_bla_send_request(struct batadv_bla_backbone_gw *backbone_gw)
 }
 
 /**
- * batadv_bla_send_announce
+ * batadv_bla_send_announce - Send an announcement frame
  * @bat_priv: the bat priv with all the soft interface information
  * @backbone_gw: our backbone gateway which should be announced
- *
- * This function sends an announcement. It is called from multiple
- * places.
  */
 static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
 				     struct batadv_bla_backbone_gw *backbone_gw)
@@ -646,8 +675,11 @@ claim_free_ref:
 	batadv_claim_free_ref(claim);
 }
 
-/* Delete a claim from the claim hash which has the
- * given mac address and vid.
+/**
+ * batadv_bla_del_claim - delete a claim from the claim hash
+ * @bat_priv: the bat priv with all the soft interface information
+ * @mac: mac address of the claim to be removed
+ * @vid: VLAN id for the claim to be removed
  */
 static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 				 const u8 *mac, const unsigned short vid)
@@ -677,6 +709,10 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 
 /**
  * batadv_handle_announce - check for ANNOUNCE frame
+ * @bat_priv: the bat priv with all the soft interface information
+ * @an_addr: announcement mac address (ARP Sender HW address)
+ * @backbone_addr: originator address of the sender (Ethernet source MAC)
+ * @vid: the VLAN ID of the frame
  *
  * Return: 1 if handled
  */
@@ -731,6 +767,11 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
 
 /**
  * batadv_handle_request - check for REQUEST frame
+ * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: the primary hard interface of this batman soft interface
+ * @backbone_addr: backbone address to be requested (ARP sender HW MAC)
+ * @ethhdr: ethernet header of a packet
+ * @vid: the VLAN ID of the frame
  *
  * Return: 1 if handled
  */
@@ -759,6 +800,11 @@ static int batadv_handle_request(struct batadv_priv *bat_priv,
 
 /**
  * batadv_handle_unclaim - check for UNCLAIM frame
+ * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: the primary hard interface of this batman soft interface
+ * @backbone_addr: originator address of the backbone (Ethernet source)
+ * @claim_addr: Client to be unclaimed (ARP sender HW MAC)
+ * @vid: the VLAN ID of the frame
  *
  * Return: 1 if handled
  */
@@ -792,6 +838,11 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 
 /**
  * batadv_handle_claim - check for CLAIM frame
+ * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: the primary hard interface of this batman soft interface
+ * @backbone_addr: originator address of the backbone (Ethernet Source)
+ * @claim_addr: client mac address to be claimed (ARP sender HW MAC)
+ * @vid: the VLAN ID of the frame
  *
  * Return: 1 if handled
  */
@@ -823,7 +874,7 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
 }
 
 /**
- * batadv_check_claim_group
+ * batadv_check_claim_group - check for claim group membership
  * @bat_priv: the bat priv with all the soft interface information
  * @primary_if: the primary interface of this batman interface
  * @hw_src: the Hardware source in the ARP Header
@@ -898,13 +949,11 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
 }
 
 /**
- * batadv_bla_process_claim
+ * batadv_bla_process_claim - Check if this is a claim frame, and process it
  * @bat_priv: the bat priv with all the soft interface information
  * @primary_if: the primary hard interface of this batman soft interface
  * @skb: the frame to be checked
  *
- * Check if this is a claim frame, and process it accordingly.
- *
  * Return: 1 if it was a claim frame, otherwise return 0 to
  * tell the callee that it can use the frame on its own.
  */
@@ -1036,7 +1085,13 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	return 1;
 }
 
-/* Check when we last heard from other nodes, and remove them in case of
+/**
+ * batadv_bla_purge_backbone_gw - Remove backbone gateways after a timeout or
+ *  immediately
+ * @bat_priv: the bat priv with all the soft interface information
+ * @now: whether the whole hash shall be wiped now
+ *
+ * Check when we last heard from other nodes, and remove them in case of
  * a time out, or clean all backbone gws if now is set.
  */
 static void batadv_bla_purge_backbone_gw(struct batadv_priv *bat_priv, int now)
@@ -1084,7 +1139,7 @@ purge_now:
 }
 
 /**
- * batadv_bla_purge_claims
+ * batadv_bla_purge_claims - Remove claims after a timeout or immediately
  * @bat_priv: the bat priv with all the soft interface information
  * @primary_if: the selected primary interface, may be NULL if now is set
  * @now: whether the whole hash shall be wiped now
@@ -1133,12 +1188,11 @@ purge_now:
 }
 
 /**
- * batadv_bla_update_orig_address
+ * batadv_bla_update_orig_address - Update the backbone gateways when the own
+ *  originator address changes
  * @bat_priv: the bat priv with all the soft interface information
  * @primary_if: the new selected primary_if
  * @oldif: the old primary interface, may be NULL
- *
- * Update the backbone gateways when the own orig address changes.
  */
 void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 				    struct batadv_hard_iface *primary_if,
@@ -1209,7 +1263,11 @@ void batadv_bla_status_update(struct net_device *net_dev)
 	batadv_hardif_free_ref(primary_if);
 }
 
-/* periodic work to do:
+/**
+ * batadv_bla_periodic_work - performs periodic bla work
+ * @work: kernel work struct
+ *
+ * periodic work to do:
  *  * purge structures when they are too old
  *  * send announcements
  */
@@ -1290,7 +1348,12 @@ out:
 static struct lock_class_key batadv_claim_hash_lock_class_key;
 static struct lock_class_key batadv_backbone_hash_lock_class_key;
 
-/* initialize all bla structures */
+/**
+ * batadv_bla_init - initialize all bla structures
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Return: 0 on success, < 0 on error.
+ */
 int batadv_bla_init(struct batadv_priv *bat_priv)
 {
 	int i;
@@ -1345,7 +1408,7 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 }
 
 /**
- * batadv_bla_check_bcast_duplist
+ * batadv_bla_check_bcast_duplist - Check if a frame is in the broadcast dup.
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: contains the bcast_packet to be checked
  *
@@ -1357,6 +1420,8 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
  * with a good chance that it is the same packet. If it is furthermore
  * sent by another host, drop it. We allow equal packets from
  * the same host however as this might be intended.
+ *
+ * Return: 1 if a packet is in the duplicate list, 0 otherwise.
  */
 int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 				   struct sk_buff *skb)
@@ -1415,13 +1480,12 @@ out:
 }
 
 /**
- * batadv_bla_is_backbone_gw_orig
+ * batadv_bla_is_backbone_gw_orig - Check if the originator is a gateway for
+ *  the VLAN identified by vid.
  * @bat_priv: the bat priv with all the soft interface information
  * @orig: originator mac address
  * @vid: VLAN identifier
  *
- * Check if the originator is a gateway for the VLAN identified by vid.
- *
  * Return: true if orig is a backbone for this vid, false otherwise.
  */
 bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
@@ -1456,13 +1520,11 @@ bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
 }
 
 /**
- * batadv_bla_is_backbone_gw
+ * batadv_bla_is_backbone_gw - check if originator is a backbone gw for a VLAN.
  * @skb: the frame to be checked
  * @orig_node: the orig_node of the frame
  * @hdr_size: maximum length of the frame
  *
- * bla_is_backbone_gw inspects the skb for the VLAN ID
- *
  * Return: 1 if the orig_node is also a gateway on the soft interface, otherwise
  * it returns 0.
  */
@@ -1491,7 +1553,12 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 	return 1;
 }
 
-/* free all bla structures (for softinterface free or module unload) */
+/**
+ * batadv_bla_init - free all bla structures
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * for softinterface free or module unload
+ */
 void batadv_bla_free(struct batadv_priv *bat_priv)
 {
 	struct batadv_hard_iface *primary_if;
@@ -1514,13 +1581,13 @@ void batadv_bla_free(struct batadv_priv *bat_priv)
 }
 
 /**
- * batadv_bla_rx
+ * batadv_bla_rx - check packets coming from the mesh.
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  * @vid: the VLAN ID of the frame
  * @is_bcast: the packet came in a broadcast packet type.
  *
- * bla_rx avoidance checks if:
+ * batadv_bla_rx avoidance checks if:
  *  * we have to race for a claim
  *  * if the frame is allowed on the LAN
  *
@@ -1610,12 +1677,12 @@ out:
 }
 
 /**
- * batadv_bla_tx
+ * batadv_bla_tx - check packets going into the mesh
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  * @vid: the VLAN ID of the frame
  *
- * bla_tx checks if:
+ * batadv_bla_tx checks if:
  *  * a claim was received which has to be processed
  *  * the frame is allowed on the mesh
  *
@@ -1698,6 +1765,13 @@ out:
 	return ret;
 }
 
+/**
+ * batadv_bla_claim_table_seq_print_text - print the claim table in a seq file
+ * @seq: seq file to print on
+ * @offset: not used
+ *
+ * Return: always 0
+ */
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
@@ -1747,6 +1821,14 @@ out:
 	return 0;
 }
 
+/**
+ * batadv_bla_backbone_table_seq_print_text - print the backbone table in a seq
+ *  file
+ * @seq: seq file to print on
+ * @offset: not used
+ *
+ * Return: always 0
+ */
 int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
-- 
2.7.0
