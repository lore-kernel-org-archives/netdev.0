From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 07/16] batman-adv: Fix kerneldoc of main functions
Date: Wed,  3 Feb 2016 10:18:28 +0800
Message-ID: <1454465917-13332-8-git-send-email-a__19855.7978649207$1454467535$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:48242 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755374AbcBCCpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:45:17 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bitarray.c       | 12 +++++++++---
 net/batman-adv/bitarray.h       | 11 +++++------
 net/batman-adv/debugfs.c        |  6 ++++++
 net/batman-adv/main.c           |  2 ++
 net/batman-adv/main.h           |  4 ++++
 net/batman-adv/originator.c     |  4 +++-
 net/batman-adv/packet.h         |  6 ++++++
 net/batman-adv/routing.c        |  7 ++++++-
 net/batman-adv/send.c           |  5 ++++-
 net/batman-adv/soft-interface.c |  2 ++
 net/batman-adv/sysfs.c          |  1 +
 11 files changed, 48 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 06bab5179bf9..3404195f2561 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -29,10 +29,16 @@ static void batadv_bitmap_shift_left(unsigned long *seq_bits, s32 n)
 	bitmap_shift_left(seq_bits, seq_bits, n, BATADV_TQ_LOCAL_WINDOW_SIZE);
 }
 
-/* receive and process one packet within the sequence number window.
+/**
+ * batadv_bit_get_packet - receive and process one packet within the sequence
+ *  number window
+ * @priv: the bat priv with all the soft interface information
+ * @seq_bits: pointer to the sequence number receive packet
+ * @seq_num_diff: difference between the current/received sequence number and
+ *  the last sequence number
+ * @set_mark: whether this packet should be marked in seq_bits
  *
- * Return:
- *  1 if the window was moved (either new or very old)
+ * Return: 1 if the window was moved (either new or very old),
  *  0 if the window was not moved/shifted.
  */
 int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index cf2aeb0831a4..2b64d7a1bc9b 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -25,7 +25,11 @@
 #include <linux/types.h>
 
 /**
- * batadv_test_bit
+ * batadv_test_bit - check if bit is set in the current window
+ *
+ * @seq_bits: pointer to the sequence number receive packet
+ * @last_seqno: latest sequence number in seq_bits
+ * @curr_seqno: sequence number to test for
  *
  * Return: 1 if the corresponding bit in the given seq_bits indicates true
  * and curr_seqno is within range of last_seqno. Otherwise returns 0.
@@ -51,11 +55,6 @@ static inline void batadv_set_bit(unsigned long *seq_bits, s32 n)
 	set_bit(n, seq_bits); /* turn the position on */
 }
 
-/**
- * batadv_bit_get_packet - receive and process one packet
- *
- * Return: 1 if received seq_num is considered new, 0 if old
- */
 int batadv_bit_get_packet(void *priv, unsigned long *seq_bits, s32 seq_num_diff,
 			  int set_mark);
 
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 037ad0a5f485..0fc9df52f3d9 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -281,6 +281,8 @@ static int batadv_originators_open(struct inode *inode, struct file *file)
  *  originator table of an hard interface
  * @inode: inode pointer to debugfs file
  * @file: pointer to the seq_file
+ *
+ * Return: 0 on success or negative error number in case of failure
  */
 static int batadv_originators_hardif_open(struct inode *inode,
 					  struct file *file)
@@ -329,6 +331,8 @@ static int batadv_bla_backbone_table_open(struct inode *inode,
  * batadv_dat_cache_open - Prepare file handler for reads from dat_chache
  * @inode: inode which was opened
  * @file: file handle to be initialized
+ *
+ * Return: 0 on success or negative error number in case of failure
  */
 static int batadv_dat_cache_open(struct inode *inode, struct file *file)
 {
@@ -483,6 +487,8 @@ void batadv_debugfs_destroy(void)
  * batadv_debugfs_add_hardif - creates the base directory for a hard interface
  *  in debugfs.
  * @hard_iface: hard interface which should be added.
+ *
+ * Return: 0 on success or negative error number in case of failure
  */
 int batadv_debugfs_add_hardif(struct batadv_hard_iface *hard_iface)
 {
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 70907f6f37ed..9d34be628304 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -599,6 +599,8 @@ int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
  *
  * payload_ptr must always point to an address in the skb head buffer and not to
  * a fragment.
+ *
+ * Return: big endian crc32c of the checksummed data
  */
 __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr)
 {
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 8a48d4a40828..34f56efa2e4e 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -275,6 +275,8 @@ static inline void _batadv_dbg(int type __always_unused,
 
 /**
  * batadv_compare_eth - Compare two not u16 aligned Ethernet addresses
+ * @data1: Pointer to a six-byte array containing the Ethernet address
+ * @data2: Pointer other six-byte array containing the Ethernet address
  *
  * note: can't use ether_addr_equal() as it requires aligned memory
  *
@@ -331,6 +333,8 @@ static inline void batadv_add_counter(struct batadv_priv *bat_priv, size_t idx,
 
 /**
  * batadv_sum_counter - Sum the cpu-local counters for index 'idx'
+ * @bat_priv: the bat priv with all the soft interface information
+ * @idx: index of counter to sum up
  *
  * Return: sum of all cpu-local counters
  */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index ed1d6d7b717e..f6ca4e509729 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -48,7 +48,9 @@ static struct lock_class_key batadv_orig_hash_lock_class_key;
 static void batadv_purge_orig(struct work_struct *work);
 
 /**
- * batadv_compare_orig
+ * batadv_compare_orig - comparing function used in the originator hash table
+ * @node: node in the local table
+ * @data2: second object to compare the node to
  *
  * Return: 1 if they are the same originator
  */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 72fd5b0a4183..fdb01637ad1f 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -209,6 +209,11 @@ struct batadv_bla_claim_dst {
  * @version: batman-adv protocol version, part of the genereal header
  * @ttl: time to live for this packet, part of the genereal header
  * @flags: contains routing relevant flags - see enum batadv_iv_flags
+ * @seqno: sequence identification
+ * @orig: address of the source node
+ * @prev_sender: address of the previous sender
+ * @reserved: reserved byte for alignment
+ * @tq: transmission quality
  * @tvlv_len: length of tvlv data following the ogm header
  */
 struct batadv_ogm_packet {
@@ -345,6 +350,7 @@ struct batadv_unicast_packet {
  * @u: common unicast packet header
  * @src: address of the source
  * @subtype: packet subtype
+ * @reserved: reserved byte for alignment
  */
 struct batadv_unicast_4addr_packet {
 	struct batadv_unicast_packet u;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index bcaa7870038b..1fb1be31bf3a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -141,8 +141,13 @@ out:
 }
 
 /**
- * batadv_window_protected checks whether the host restarted and is in the
+ * batadv_window_protected - checks whether the host restarted and is in the
  *  protection time.
+ * @bat_priv: the bat priv with all the soft interface information
+ * @seq_num_diff: difference between the current/received sequence number and
+ *  the last sequence number
+ * @last_reset: jiffies timestamp of the last reset, will be updated when reset
+ *  is detected
  *
  * Return:
  *  0 if the packet is to be accepted.
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index d9b93c567bbc..c188f4660981 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -431,7 +431,10 @@ _batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 }
 
 /**
- * batadv_add_bcast_packet_to_list
+ * batadv_add_bcast_packet_to_list - queue broadcast packet for multiple sends
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: broadcast packet to add
+ * @delay: number of jiffies to wait before sending
  *
  * add a broadcast packet to the queue and setup timers. broadcast packets
  * are sent multiple times to increase probability for being received.
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 5ee794b62392..6c65de97126c 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -594,6 +594,7 @@ static void batadv_softif_destroy_vlan(struct batadv_priv *bat_priv,
 /**
  * batadv_interface_add_vid - ndo_add_vid API implementation
  * @dev: the netdev of the mesh interface
+ * @proto: protocol of the the vlan id
  * @vid: identifier of the new vlan
  *
  * Set up all the internal structures for handling the new vlan on top of the
@@ -651,6 +652,7 @@ static int batadv_interface_add_vid(struct net_device *dev, __be16 proto,
 /**
  * batadv_interface_kill_vid - ndo_kill_vid API implementation
  * @dev: the netdev of the mesh interface
+ * @proto: protocol of the the vlan id
  * @vid: identifier of the deleted vlan
  *
  * Destroy all the internal structures used to handle the vlan identified by vid
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 7658e6ea0596..f38d7b75b0a5 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -82,6 +82,7 @@ static struct batadv_priv *batadv_vlan_kobj_to_batpriv(struct kobject *obj)
 
 /**
  * batadv_kobj_to_vlan - convert a kobj in the associated softif_vlan struct
+ * @bat_priv: the bat priv with all the soft interface information
  * @obj: kobject to covert
  *
  * Return: the associated softif_vlan struct if found, NULL otherwise.
-- 
2.7.0
