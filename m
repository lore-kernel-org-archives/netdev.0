From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 4/7] batman-adv: Add required includes to all files
Date: Tue,  9 Jun 2015 12:50:17 +0200
Message-ID: <1433847020-1427-5-git-send-email-antonio@meshcoding.com>
References: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:13267 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932239AbbFIKwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 06:52:30 -0400
In-Reply-To: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The header files could not be build indepdent from each other. This is
happened because headers didn't include the files for things they've used.
This was problematic because the success of a build depended on the
knowledge about the right order of local includes.

Also source files were not including everything they've used explicitly.
Instead they required that transitive includes are always stable. This is
problematic because some transitive includes are not obvious, depend on
config settings and may not be stable in the future.

The order for include blocks are:

 * primary headers (main.h and the *.h file of a *.c file)
 * global linux headers
 * required local headers
 * extra forward declarations for pointers in function/struct declarations

The only exceptions are linux/bitops.h and linux/if_ether.h in packet.h.
This header file is shared with userspace applications like batctl and must
therefore build together with userspace applications. The header
linux/bitops.h is not part of the uapi headers and linux/if_ether.h
conflicts with the musl implementation of netinet/if_ether.h. The
maintainers rejected the use of __KERNEL__ preprocessor checks and thus
these two headers are only in main.h. All files using packet.h first have
to include main.h to work correctly.

Reported-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c            | 46 +++++++++++++++++++++-----
 net/batman-adv/bitarray.c              |  4 +--
 net/batman-adv/bitarray.h              |  6 ++++
 net/batman-adv/bridge_loop_avoidance.c | 38 ++++++++++++++++-----
 net/batman-adv/bridge_loop_avoidance.h | 10 ++++++
 net/batman-adv/debugfs.c               | 37 ++++++++++++++++-----
 net/batman-adv/debugfs.h               |  7 ++++
 net/batman-adv/distributed-arp-table.c | 28 +++++++++++++---
 net/batman-adv/distributed-arp-table.h | 13 ++++++--
 net/batman-adv/fragmentation.c         | 24 +++++++++++---
 net/batman-adv/fragmentation.h         |  9 +++++
 net/batman-adv/gateway_client.c        | 34 +++++++++++++++----
 net/batman-adv/gateway_client.h        |  8 +++++
 net/batman-adv/gateway_common.c        | 11 ++++++-
 net/batman-adv/gateway_common.h        |  7 ++++
 net/batman-adv/hard-interface.c        | 38 ++++++++++++++-------
 net/batman-adv/hard-interface.h        | 11 +++++++
 net/batman-adv/hash.c                  |  6 +++-
 net/batman-adv/hash.h                  |  9 +++++
 net/batman-adv/icmp_socket.c           | 37 +++++++++++++++++----
 net/batman-adv/icmp_socket.h           |  7 ++++
 net/batman-adv/main.c                  | 60 +++++++++++++++++++++++-----------
 net/batman-adv/main.h                  | 29 ++++++++--------
 net/batman-adv/multicast.c             | 29 ++++++++++++++--
 net/batman-adv/multicast.h             |  6 ++++
 net/batman-adv/network-coding.c        | 41 +++++++++++++++++++----
 net/batman-adv/network-coding.h        | 13 ++++++++
 net/batman-adv/originator.c            | 30 ++++++++++++-----
 net/batman-adv/originator.h            | 13 ++++++++
 net/batman-adv/packet.h                |  3 ++
 net/batman-adv/routing.c               | 36 ++++++++++++++------
 net/batman-adv/routing.h               | 10 ++++++
 net/batman-adv/send.c                  | 40 ++++++++++++++++-------
 net/batman-adv/send.h                  | 13 ++++++++
 net/batman-adv/soft-interface.c        | 54 +++++++++++++++++++++---------
 net/batman-adv/soft-interface.h        | 11 +++++++
 net/batman-adv/sysfs.c                 | 33 +++++++++++++++----
 net/batman-adv/sysfs.h                 | 10 ++++++
 net/batman-adv/translation-table.c     | 41 ++++++++++++++++++-----
 net/batman-adv/translation-table.h     |  9 +++++
 net/batman-adv/types.h                 | 18 ++++++++--
 41 files changed, 717 insertions(+), 172 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 4e93d2d..9adbc61 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -15,16 +15,46 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
-#include "translation-table.h"
-#include "originator.h"
-#include "routing.h"
-#include "gateway_common.h"
-#include "gateway_client.h"
-#include "hard-interface.h"
-#include "send.h"
 #include "bat_algo.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/bitmap.h>
+#include <linux/bitops.h>
+#include <linux/bug.h>
+#include <linux/byteorder/generic.h>
+#include <linux/cache.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/init.h>
+#include <linux/jiffies.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/pkt_sched.h>
+#include <linux/printk.h>
+#include <linux/random.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/seq_file.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+
+#include "bitarray.h"
+#include "hard-interface.h"
+#include "hash.h"
 #include "network-coding.h"
+#include "originator.h"
+#include "packet.h"
+#include "routing.h"
+#include "send.h"
+#include "translation-table.h"
 
 /**
  * enum batadv_dup_status - duplicate status
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 40e4a2a..cf68c32 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -15,10 +15,10 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "bitarray.h"
+#include "main.h"
 
-#include <linux/bitops.h>
+#include <linux/bitmap.h>
 
 /* shift the packet array by n places. */
 static void batadv_bitmap_shift_left(unsigned long *seq_bits, int32_t n)
diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index be497be..0c24562 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -18,6 +18,12 @@
 #ifndef _NET_BATMAN_ADV_BITARRAY_H_
 #define _NET_BATMAN_ADV_BITARRAY_H_
 
+#include "main.h"
+
+#include <linux/bitops.h>
+#include <linux/compiler.h>
+#include <linux/types.h>
+
 /* Returns 1 if the corresponding bit in the given seq_bits indicates true
  * and curr_seqno is within range of last_seqno. Otherwise returns 0.
  */
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index f2ac903..ba06092 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -15,19 +15,41 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
-#include "hash.h"
-#include "hard-interface.h"
-#include "originator.h"
 #include "bridge_loop_avoidance.h"
-#include "translation-table.h"
-#include "send.h"
+#include "main.h"
 
-#include <linux/etherdevice.h>
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/compiler.h>
 #include <linux/crc16.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
 #include <linux/if_arp.h>
-#include <net/arp.h>
+#include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/jhash.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/lockdep.h>
+#include <linux/netdevice.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/seq_file.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/workqueue.h>
+#include <net/arp.h>
+
+#include "hard-interface.h"
+#include "hash.h"
+#include "originator.h"
+#include "packet.h"
+#include "translation-table.h"
 
 static const uint8_t batadv_announce_mac[4] = {0x43, 0x05, 0x43, 0x05};
 
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 1f506d3..0282690 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -18,6 +18,16 @@
 #ifndef _NET_BATMAN_ADV_BLA_H_
 #define _NET_BATMAN_ADV_BLA_H_
 
+#include "main.h"
+
+#include <linux/types.h>
+
+struct batadv_hard_iface;
+struct batadv_orig_node;
+struct batadv_priv;
+struct seq_file;
+struct sk_buff;
+
 #ifdef CONFIG_BATMAN_ADV_BLA
 int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 		  unsigned short vid, bool is_bcast);
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 4611808..c4c1e80 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -15,21 +15,42 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
+#include "debugfs.h"
 #include "main.h"
 
+#include <linux/compiler.h>
 #include <linux/debugfs.h>
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/export.h>
+#include <linux/fcntl.h>
+#include <linux/fs.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/poll.h>
+#include <linux/printk.h>
+#include <linux/sched.h> /* for linux/wait.h */
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stat.h>
+#include <linux/stddef.h>
+#include <linux/stringify.h>
+#include <linux/sysfs.h>
+#include <linux/types.h>
+#include <linux/uaccess.h>
+#include <linux/wait.h>
+#include <stdarg.h>
 
-#include "debugfs.h"
-#include "translation-table.h"
-#include "originator.h"
-#include "hard-interface.h"
-#include "gateway_common.h"
-#include "gateway_client.h"
-#include "soft-interface.h"
-#include "icmp_socket.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
+#include "gateway_client.h"
+#include "icmp_socket.h"
 #include "network-coding.h"
+#include "originator.h"
+#include "translation-table.h"
 
 static struct dentry *batadv_debugfs;
 
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index ed25605..187acdc 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -18,6 +18,13 @@
 #ifndef _NET_BATMAN_ADV_DEBUGFS_H_
 #define _NET_BATMAN_ADV_DEBUGFS_H_
 
+#include "main.h"
+
+#include <linux/kconfig.h>
+
+struct batadv_hard_iface;
+struct net_device;
+
 #define BATADV_DEBUGFS_SUBDIR "batman_adv"
 
 #if IS_ENABLED(CONFIG_DEBUG_FS)
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 2e6198e..fb54e6a 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -15,18 +15,36 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include <linux/if_ether.h>
+#include "distributed-arp-table.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
 #include <linux/if_arp.h>
+#include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/in.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/seq_file.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/workqueue.h>
 #include <net/arp.h>
 
-#include "main.h"
-#include "hash.h"
-#include "distributed-arp-table.h"
 #include "hard-interface.h"
+#include "hash.h"
 #include "originator.h"
 #include "send.h"
-#include "types.h"
 #include "translation-table.h"
 
 static void batadv_dat_purge(struct work_struct *work);
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index ed41b8e..3181507 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -18,12 +18,19 @@
 #ifndef _NET_BATMAN_ADV_DISTRIBUTED_ARP_TABLE_H_
 #define _NET_BATMAN_ADV_DISTRIBUTED_ARP_TABLE_H_
 
-#ifdef CONFIG_BATMAN_ADV_DAT
+#include "main.h"
+
+#include <linux/compiler.h>
+#include <linux/netdevice.h>
+#include <linux/types.h>
 
-#include "types.h"
 #include "originator.h"
+#include "packet.h"
 
-#include <linux/if_arp.h>
+struct seq_file;
+struct sk_buff;
+
+#ifdef CONFIG_BATMAN_ADV_DAT
 
 /* BATADV_DAT_ADDR_MAX - maximum address value in the DHT space */
 #define BATADV_DAT_ADDR_MAX ((batadv_dat_addr_t)~(batadv_dat_addr_t)0)
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 6ce3c84..c0f0d01 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -15,12 +15,28 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "fragmentation.h"
-#include "send.h"
-#include "originator.h"
-#include "routing.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/pkt_sched.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+
 #include "hard-interface.h"
+#include "originator.h"
+#include "packet.h"
+#include "routing.h"
+#include "send.h"
 #include "soft-interface.h"
 
 /**
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentation.h
index ec1e86f..8b9877e 100644
--- a/net/batman-adv/fragmentation.h
+++ b/net/batman-adv/fragmentation.h
@@ -18,6 +18,15 @@
 #ifndef _NET_BATMAN_ADV_FRAGMENTATION_H_
 #define _NET_BATMAN_ADV_FRAGMENTATION_H_
 
+#include "main.h"
+
+#include <linux/compiler.h>
+#include <linux/list.h>
+#include <linux/stddef.h>
+#include <linux/types.h>
+
+struct sk_buff;
+
 void batadv_frag_purge_orig(struct batadv_orig_node *orig,
 			    bool (*check_cb)(struct batadv_frag_table_entry *));
 bool batadv_frag_skb_fwd(struct sk_buff *skb,
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index a85eaca..14f0a22 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -15,18 +15,38 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
-#include "sysfs.h"
 #include "gateway_client.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/seq_file.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/udp.h>
+
 #include "gateway_common.h"
 #include "hard-interface.h"
 #include "originator.h"
-#include "translation-table.h"
+#include "packet.h"
 #include "routing.h"
-#include <linux/ip.h>
-#include <linux/ipv6.h>
-#include <linux/udp.h>
-#include <linux/if_vlan.h>
+#include "sysfs.h"
+#include "translation-table.h"
 
 /* These are the offsets of the "hw type" and "hw address length" in the dhcp
  * packet starting at the beginning of the dhcp header
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 185fb08..89565b4 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -18,6 +18,14 @@
 #ifndef _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
 #define _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
 
+#include "main.h"
+
+#include <linux/types.h>
+
+struct batadv_tvlv_gateway_data;
+struct seq_file;
+struct sk_buff;
+
 void batadv_gw_check_client_stop(struct batadv_priv *bat_priv);
 void batadv_gw_reselect(struct batadv_priv *bat_priv);
 void batadv_gw_election(struct batadv_priv *bat_priv);
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 0792e2f..39cf44c 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -15,9 +15,18 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "gateway_common.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+
 #include "gateway_client.h"
+#include "packet.h"
 
 /**
  * batadv_parse_gw_bandwidth - parse supplied string buffer to extract download
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index df54342..bd5c812 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -18,6 +18,13 @@
 #ifndef _NET_BATMAN_ADV_GATEWAY_COMMON_H_
 #define _NET_BATMAN_ADV_GATEWAY_COMMON_H_
 
+#include "main.h"
+
+#include <linux/types.h>
+
+struct batadv_priv;
+struct net_device;
+
 enum batadv_gw_modes {
 	BATADV_GW_MODE_OFF,
 	BATADV_GW_MODE_CLIENT,
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index bdb020e..f4a15d2 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -15,22 +15,36 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
-#include "distributed-arp-table.h"
 #include "hard-interface.h"
-#include "soft-interface.h"
-#include "send.h"
-#include "translation-table.h"
-#include "routing.h"
-#include "sysfs.h"
-#include "debugfs.h"
-#include "originator.h"
-#include "hash.h"
-#include "bridge_loop_avoidance.h"
-#include "gateway_client.h"
+#include "main.h"
 
+#include <linux/bug.h>
+#include <linux/byteorder/generic.h>
+#include <linux/errno.h>
+#include <linux/fs.h>
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
+#include <linux/if.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/printk.h>
+#include <linux/rculist.h>
+#include <linux/rtnetlink.h>
+#include <linux/slab.h>
+#include <linux/workqueue.h>
+#include <net/net_namespace.h>
+
+#include "bridge_loop_avoidance.h"
+#include "debugfs.h"
+#include "distributed-arp-table.h"
+#include "gateway_client.h"
+#include "originator.h"
+#include "packet.h"
+#include "send.h"
+#include "soft-interface.h"
+#include "sysfs.h"
+#include "translation-table.h"
 
 void batadv_hardif_free_rcu(struct rcu_head *rcu)
 {
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index e8b6ffe..5a31420 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -18,6 +18,17 @@
 #ifndef _NET_BATMAN_ADV_HARD_INTERFACE_H_
 #define _NET_BATMAN_ADV_HARD_INTERFACE_H_
 
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/compiler.h>
+#include <linux/notifier.h>
+#include <linux/rcupdate.h>
+#include <linux/stddef.h>
+#include <linux/types.h>
+
+struct net_device;
+
 enum batadv_hard_if_state {
 	BATADV_IF_NOT_IN_USE,
 	BATADV_IF_TO_BE_REMOVED,
diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index 3a0e1dc..e89f314 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -15,8 +15,12 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "hash.h"
+#include "main.h"
+
+#include <linux/fs.h>
+#include <linux/lockdep.h>
+#include <linux/slab.h>
 
 /* clears the hash */
 static void batadv_hash_init(struct batadv_hashtable *hash)
diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index bcf427c..5065f50 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -18,7 +18,16 @@
 #ifndef _NET_BATMAN_ADV_HASH_H_
 #define _NET_BATMAN_ADV_HASH_H_
 
+#include "main.h"
+
+#include <linux/compiler.h>
 #include <linux/list.h>
+#include <linux/rculist.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/types.h>
+
+struct lock_class_key;
 
 /* callback to a compare function.  should compare 2 element datas for their
  * keys, return 0 if same and not 0 if not same
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 6c3cfb5..07061bc 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -15,14 +15,39 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
-#include <linux/debugfs.h>
-#include <linux/slab.h>
 #include "icmp_socket.h"
-#include "send.h"
-#include "hash.h"
-#include "originator.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/compiler.h>
+#include <linux/debugfs.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/export.h>
+#include <linux/fcntl.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/pkt_sched.h>
+#include <linux/poll.h>
+#include <linux/printk.h>
+#include <linux/sched.h> /* for linux/wait.h */
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stat.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/uaccess.h>
+#include <linux/wait.h>
+
 #include "hard-interface.h"
+#include "originator.h"
+#include "packet.h"
+#include "send.h"
 
 static struct batadv_socket_client *batadv_socket_client_hash[256];
 
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 4815824..7de7fce 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -18,6 +18,13 @@
 #ifndef _NET_BATMAN_ADV_ICMP_SOCKET_H_
 #define _NET_BATMAN_ADV_ICMP_SOCKET_H_
 
+#include "main.h"
+
+#include <linux/types.h>
+
+struct batadv_icmp_header;
+struct batadv_priv;
+
 #define BATADV_ICMP_SOCKET "socket"
 
 void batadv_socket_init(void);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 548e405..8457097 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -15,31 +15,53 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include <linux/crc32c.h>
-#include <linux/highmem.h>
-#include <linux/if_vlan.h>
-#include <net/ip.h>
-#include <net/ipv6.h>
-#include <net/dsfield.h>
 #include "main.h"
-#include "sysfs.h"
+
+#include <linux/atomic.h>
+#include <linux/bug.h>
+#include <linux/byteorder/generic.h>
+#include <linux/crc32c.h>
+#include <linux/errno.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/init.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/netdevice.h>
+#include <linux/pkt_sched.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/seq_file.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/workqueue.h>
+#include <net/dsfield.h>
+#include <net/rtnetlink.h>
+
+#include "bat_algo.h"
+#include "bridge_loop_avoidance.h"
 #include "debugfs.h"
+#include "distributed-arp-table.h"
+#include "gateway_client.h"
+#include "gateway_common.h"
+#include "hard-interface.h"
+#include "icmp_socket.h"
+#include "multicast.h"
+#include "network-coding.h"
+#include "originator.h"
+#include "packet.h"
 #include "routing.h"
 #include "send.h"
-#include "originator.h"
 #include "soft-interface.h"
-#include "icmp_socket.h"
 #include "translation-table.h"
-#include "hard-interface.h"
-#include "gateway_client.h"
-#include "bridge_loop_avoidance.h"
-#include "distributed-arp-table.h"
-#include "multicast.h"
-#include "gateway_common.h"
-#include "hash.h"
-#include "bat_algo.h"
-#include "network-coding.h"
-#include "fragmentation.h"
 
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
  * list traversals just rcu-locked
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 985d017..bf0019a4 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -163,28 +163,25 @@ enum batadv_uev_type {
 
 /* Kernel headers */
 
-#include <linux/mutex.h>	/* mutex */
-#include <linux/module.h>	/* needed by all modules */
-#include <linux/netdevice.h>	/* netdevice */
-#include <linux/etherdevice.h>  /* ethernet address classification */
-#include <linux/if_ether.h>	/* ethernet header */
-#include <linux/poll.h>		/* poll_table */
-#include <linux/kthread.h>	/* kernel threads */
-#include <linux/pkt_sched.h>	/* schedule types */
-#include <linux/workqueue.h>	/* workqueue */
+#include <linux/atomic.h>
+#include <linux/bitops.h> /* for packet.h */
+#include <linux/compiler.h>
+#include <linux/cpumask.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h> /* for packet.h */
+#include <linux/netdevice.h>
+#include <linux/printk.h>
+#include <linux/types.h>
 #include <linux/percpu.h>
-#include <linux/slab.h>
-#include <linux/jhash.h>
-#include <net/sock.h>		/* struct sock */
-#include <net/addrconf.h>	/* ipv6 address stuff */
-#include <linux/ip.h>
-#include <net/rtnetlink.h>
 #include <linux/jiffies.h>
-#include <linux/seq_file.h>
 #include <linux/if_vlan.h>
 
 #include "types.h"
 
+struct batadv_ogm_packet;
+struct seq_file;
+struct sk_buff;
+
 #define BATADV_PRINT_VID(vid) (vid & BATADV_VLAN_HAS_TAG ? \
 			       (int)(vid & VLAN_VID_MASK) : -1)
 
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 09f2838..7aa480b 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -15,10 +15,33 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "multicast.h"
-#include "originator.h"
-#include "hard-interface.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/in6.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <net/addrconf.h>
+#include <net/ipv6.h>
+
+#include "packet.h"
 #include "translation-table.h"
 
 /**
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index 033d80e..beb6e56 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -18,6 +18,12 @@
 #ifndef _NET_BATMAN_ADV_MULTICAST_H_
 #define _NET_BATMAN_ADV_MULTICAST_H_
 
+#include "main.h"
+
+struct batadv_orig_node;
+struct batadv_priv;
+struct sk_buff;
+
 /**
  * batadv_forw_mode - the way a packet should be forwarded as
  * @BATADV_FORW_ALL: forward the packet to all nodes (currently via classic
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index fb54319a..f0a50f3 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -15,15 +15,44 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include <linux/debugfs.h>
-
-#include "main.h"
-#include "hash.h"
 #include "network-coding.h"
-#include "send.h"
-#include "originator.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/compiler.h>
+#include <linux/debugfs.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/if_packet.h>
+#include <linux/init.h>
+#include <linux/jhash.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/lockdep.h>
+#include <linux/netdevice.h>
+#include <linux/printk.h>
+#include <linux/random.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/seq_file.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stat.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/workqueue.h>
+
 #include "hard-interface.h"
+#include "hash.h"
+#include "originator.h"
+#include "packet.h"
 #include "routing.h"
+#include "send.h"
 
 static struct lock_class_key batadv_nc_coding_hash_lock_class_key;
 static struct lock_class_key batadv_nc_decoding_hash_lock_class_key;
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-coding.h
index b5ab8ff..5b79aa8 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -18,6 +18,19 @@
 #ifndef _NET_BATMAN_ADV_NETWORK_CODING_H_
 #define _NET_BATMAN_ADV_NETWORK_CODING_H_
 
+#include "main.h"
+
+#include <linux/types.h>
+
+struct batadv_nc_node;
+struct batadv_neigh_node;
+struct batadv_ogm_packet;
+struct batadv_orig_node;
+struct batadv_priv;
+struct net_device;
+struct seq_file;
+struct sk_buff;
+
 #ifdef CONFIG_BATMAN_ADV_NC
 
 void batadv_nc_status_update(struct net_device *net_dev);
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index aa092c3..018b749 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -15,19 +15,31 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
-#include "distributed-arp-table.h"
 #include "originator.h"
-#include "hash.h"
-#include "translation-table.h"
-#include "routing.h"
+#include "main.h"
+
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/lockdep.h>
+#include <linux/netdevice.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+
+#include "distributed-arp-table.h"
+#include "fragmentation.h"
 #include "gateway_client.h"
 #include "hard-interface.h"
-#include "soft-interface.h"
-#include "bridge_loop_avoidance.h"
-#include "network-coding.h"
-#include "fragmentation.h"
+#include "hash.h"
 #include "multicast.h"
+#include "network-coding.h"
+#include "routing.h"
+#include "translation-table.h"
 
 /* hash class keys */
 static struct lock_class_key batadv_orig_hash_lock_class_key;
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 0b716fe..79734d3 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -18,8 +18,21 @@
 #ifndef _NET_BATMAN_ADV_ORIGINATOR_H_
 #define _NET_BATMAN_ADV_ORIGINATOR_H_
 
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/compiler.h>
+#include <linux/if_ether.h>
+#include <linux/jhash.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/stddef.h>
+#include <linux/types.h>
+
 #include "hash.h"
 
+struct seq_file;
+
 int batadv_compare_orig(const struct hlist_node *node, const void *data2);
 int batadv_originator_init(struct batadv_priv *bat_priv);
 void batadv_originator_free(struct batadv_priv *bat_priv);
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 9468bc0..9e747c0 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -18,6 +18,9 @@
 #ifndef _NET_BATMAN_ADV_PACKET_H_
 #define _NET_BATMAN_ADV_PACKET_H_
 
+#include <asm/byteorder.h>
+#include <linux/types.h>
+
 /**
  * enum batadv_packettype - types for batman-adv encapsulated packets
  * @BATADV_IV_OGM: originator messages for B.A.T.M.A.N. IV
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index c5d9009..c360c0c 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -15,20 +15,36 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "routing.h"
-#include "send.h"
-#include "soft-interface.h"
-#include "hard-interface.h"
-#include "icmp_socket.h"
-#include "translation-table.h"
-#include "originator.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/compiler.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/jiffies.h>
+#include <linux/netdevice.h>
+#include <linux/printk.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+
+#include "bitarray.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
-#include "network-coding.h"
 #include "fragmentation.h"
-
-#include <linux/if_vlan.h>
+#include "hard-interface.h"
+#include "icmp_socket.h"
+#include "network-coding.h"
+#include "originator.h"
+#include "packet.h"
+#include "send.h"
+#include "soft-interface.h"
+#include "translation-table.h"
 
 static int batadv_route_unicast_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if);
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 6573f12..6bc29d3 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -18,6 +18,16 @@
 #ifndef _NET_BATMAN_ADV_ROUTING_H_
 #define _NET_BATMAN_ADV_ROUTING_H_
 
+#include "main.h"
+
+#include <linux/types.h>
+
+struct batadv_hard_iface;
+struct batadv_neigh_node;
+struct batadv_orig_node;
+struct batadv_priv;
+struct sk_buff;
+
 bool batadv_check_management_packet(struct sk_buff *skb,
 				    struct batadv_hard_iface *hard_iface,
 				    int header_len);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 23635bd..0a01992 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -15,19 +15,37 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
-#include "distributed-arp-table.h"
 #include "send.h"
-#include "routing.h"
-#include "translation-table.h"
-#include "soft-interface.h"
-#include "hard-interface.h"
-#include "gateway_common.h"
-#include "gateway_client.h"
-#include "originator.h"
-#include "network-coding.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/if.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/printk.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/workqueue.h>
+
+#include "distributed-arp-table.h"
 #include "fragmentation.h"
-#include "multicast.h"
+#include "gateway_client.h"
+#include "hard-interface.h"
+#include "network-coding.h"
+#include "originator.h"
+#include "routing.h"
+#include "soft-interface.h"
+#include "translation-table.h"
 
 static void batadv_send_outstanding_bcast_packet(struct work_struct *work);
 
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 60c233e..0536835 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -18,6 +18,19 @@
 #ifndef _NET_BATMAN_ADV_SEND_H_
 #define _NET_BATMAN_ADV_SEND_H_
 
+#include "main.h"
+
+#include <linux/compiler.h>
+#include <linux/types.h>
+
+#include "packet.h"
+
+struct batadv_hard_iface;
+struct batadv_orig_node;
+struct batadv_priv;
+struct sk_buff;
+struct work_struct;
+
 int batadv_send_skb_packet(struct sk_buff *skb,
 			   struct batadv_hard_iface *hard_iface,
 			   const uint8_t *dst_addr);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 50cf722..a859322 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -15,26 +15,50 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "soft-interface.h"
-#include "hard-interface.h"
-#include "distributed-arp-table.h"
-#include "routing.h"
-#include "send.h"
-#include "debugfs.h"
-#include "translation-table.h"
-#include "hash.h"
-#include "gateway_common.h"
-#include "gateway_client.h"
-#include "sysfs.h"
-#include "originator.h"
-#include <linux/slab.h>
-#include <linux/ethtool.h>
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/byteorder/generic.h>
+#include <linux/cache.h>
+#include <linux/compiler.h>
+#include <linux/errno.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
 #include <linux/if_vlan.h>
-#include "multicast.h"
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/lockdep.h>
+#include <linux/netdevice.h>
+#include <linux/percpu.h>
+#include <linux/printk.h>
+#include <linux/random.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/socket.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+
 #include "bridge_loop_avoidance.h"
+#include "debugfs.h"
+#include "distributed-arp-table.h"
+#include "gateway_client.h"
+#include "gateway_common.h"
+#include "hard-interface.h"
+#include "multicast.h"
 #include "network-coding.h"
+#include "packet.h"
+#include "send.h"
+#include "sysfs.h"
+#include "translation-table.h"
 
 static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
 static void batadv_get_drvinfo(struct net_device *dev,
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 9ce0804..578e8a6 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -18,6 +18,17 @@
 #ifndef _NET_BATMAN_ADV_SOFT_INTERFACE_H_
 #define _NET_BATMAN_ADV_SOFT_INTERFACE_H_
 
+#include "main.h"
+
+#include <net/rtnetlink.h>
+
+struct batadv_hard_iface;
+struct batadv_orig_node;
+struct batadv_priv;
+struct batadv_softif_vlan;
+struct net_device;
+struct sk_buff;
+
 int batadv_skb_head_push(struct sk_buff *skb, unsigned int len);
 void batadv_interface_rx(struct net_device *soft_iface,
 			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 7278b2b..d6a312a 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -15,16 +15,35 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "sysfs.h"
-#include "translation-table.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/compiler.h>
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/fs.h>
+#include <linux/if.h>
+#include <linux/if_vlan.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/printk.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/rtnetlink.h>
+#include <linux/slab.h>
+#include <linux/stat.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/stringify.h>
+
 #include "distributed-arp-table.h"
-#include "network-coding.h"
-#include "originator.h"
-#include "hard-interface.h"
-#include "soft-interface.h"
-#include "gateway_common.h"
 #include "gateway_client.h"
+#include "gateway_common.h"
+#include "hard-interface.h"
+#include "network-coding.h"
+#include "packet.h"
+#include "soft-interface.h"
 
 static struct net_device *batadv_kobj_to_netdev(struct kobject *obj)
 {
diff --git a/net/batman-adv/sysfs.h b/net/batman-adv/sysfs.h
index b9e79ad..2294583 100644
--- a/net/batman-adv/sysfs.h
+++ b/net/batman-adv/sysfs.h
@@ -18,6 +18,16 @@
 #ifndef _NET_BATMAN_ADV_SYSFS_H_
 #define _NET_BATMAN_ADV_SYSFS_H_
 
+#include "main.h"
+
+#include <linux/sysfs.h>
+#include <linux/types.h>
+
+struct batadv_priv;
+struct batadv_softif_vlan;
+struct kobject;
+struct net_device;
+
 #define BATADV_SYSFS_IF_MESH_SUBDIR "mesh"
 #define BATADV_SYSFS_IF_BAT_SUBDIR "batman_adv"
 /**
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index fe9f824..0611c58 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -15,18 +15,41 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  */
 
-#include "main.h"
 #include "translation-table.h"
-#include "soft-interface.h"
-#include "hard-interface.h"
-#include "send.h"
-#include "hash.h"
-#include "originator.h"
-#include "routing.h"
-#include "bridge_loop_avoidance.h"
-#include "multicast.h"
+#include "main.h"
 
+#include <linux/atomic.h>
+#include <linux/bug.h>
+#include <linux/byteorder/generic.h>
+#include <linux/compiler.h>
 #include <linux/crc32c.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/jhash.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/lockdep.h>
+#include <linux/netdevice.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/workqueue.h>
+#include <net/net_namespace.h>
+
+#include "bridge_loop_avoidance.h"
+#include "hard-interface.h"
+#include "hash.h"
+#include "multicast.h"
+#include "originator.h"
+#include "packet.h"
+#include "soft-interface.h"
 
 /* hash class keys */
 static struct lock_class_key batadv_tt_local_hash_lock_class_key;
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 5769037c..6acc25d 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -18,6 +18,15 @@
 #ifndef _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 
+#include "main.h"
+
+#include <linux/types.h>
+
+struct batadv_orig_node;
+struct batadv_priv;
+struct net_device;
+struct seq_file;
+
 int batadv_tt_init(struct batadv_priv *bat_priv);
 bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 			 unsigned short vid, int ifindex, uint32_t mark);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 336f94b..67d6348 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -18,9 +18,23 @@
 #ifndef _NET_BATMAN_ADV_TYPES_H_
 #define _NET_BATMAN_ADV_TYPES_H_
 
+#ifndef _NET_BATMAN_ADV_MAIN_H_
+#error only "main.h" can be included directly
+#endif
+
+#include <linux/bitops.h>
+#include <linux/compiler.h>
+#include <linux/if_ether.h>
+#include <linux/netdevice.h>
+#include <linux/sched.h> /* for linux/wait.h */
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/wait.h>
+#include <linux/workqueue.h>
+
 #include "packet.h"
-#include "bitarray.h"
-#include <linux/kernel.h>
+
+struct seq_file;
 
 #ifdef CONFIG_BATMAN_ADV_DAT
 
-- 
2.4.2
