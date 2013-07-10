From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next 1/3] net: rename include/net/ll_poll.h to
 include/net/busy_poll.h
Date: Wed, 10 Jul 2013 14:54:59 +0300
Message-ID: <20130710115459.12715.80492.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jonathan Corbet <corbet@lwn.net>,
	e1000-devel@lists.sourceforge.net,
	Eilon Greenstein <eilong@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24272 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173Ab3GJLzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 07:55:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the file and correct all the places where it is included.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    2 
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    2 
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |    2 
 fs/select.c                                     |    2 
 include/net/busy_poll.h                         |  183 +++++++++++++++++++++++
 include/net/ll_poll.h                           |  183 -----------------------
 net/core/datagram.c                             |    2 
 net/core/sock.c                                 |    2 
 net/core/sysctl_net_core.c                      |    2 
 net/ipv4/tcp.c                                  |    2 
 net/ipv4/tcp_ipv4.c                             |    2 
 net/ipv4/udp.c                                  |    2 
 net/ipv6/tcp_ipv6.c                             |    2 
 net/ipv6/udp.c                                  |    2 
 net/socket.c                                    |    2 
 16 files changed, 197 insertions(+), 197 deletions(-)
 create mode 100644 include/net/busy_poll.h
 delete mode 100644 include/net/ll_poll.h

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ec3aa1d..05b6b4e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -24,7 +24,7 @@
 #include <net/tcp.h>
 #include <net/ipv6.h>
 #include <net/ip6_checksum.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 #include <linux/prefetch.h>
 #include "bnx2x_cmn.h"
 #include "bnx2x_init.h"
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index fb098b4..7be725c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -52,7 +52,7 @@
 #include <linux/dca.h>
 #endif
 
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 #ifdef CONFIG_NET_LL_RX_POLL
 #define LL_EXTENDED_STATS
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index caf2047..0fb2438 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -38,7 +38,7 @@
 #include <linux/slab.h>
 #include <linux/hash.h>
 #include <net/ip.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 76997b9..90746d3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -31,7 +31,7 @@
  *
  */
 
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 #include <linux/mlx4/cq.h>
 #include <linux/slab.h>
 #include <linux/mlx4/qp.h>
diff --git a/fs/select.c b/fs/select.c
index 50a804b..ebd2d58 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -27,7 +27,7 @@
 #include <linux/rcupdate.h>
 #include <linux/hrtimer.h>
 #include <linux/sched/rt.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 #include <asm/uaccess.h>
 
diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
new file mode 100644
index 0000000..76f0340
--- /dev/null
+++ b/include/net/busy_poll.h
@@ -0,0 +1,183 @@
+/*
+ * Low Latency Sockets
+ * Copyright(c) 2013 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Author: Eliezer Tamir
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ */
+
+#ifndef _LINUX_NET_LL_POLL_H
+#define _LINUX_NET_LL_POLL_H
+
+#include <linux/netdevice.h>
+#include <net/ip.h>
+
+#ifdef CONFIG_NET_LL_RX_POLL
+
+struct napi_struct;
+extern unsigned int sysctl_net_ll_read __read_mostly;
+extern unsigned int sysctl_net_ll_poll __read_mostly;
+
+/* return values from ndo_ll_poll */
+#define LL_FLUSH_FAILED		-1
+#define LL_FLUSH_BUSY		-2
+
+static inline bool net_busy_loop_on(void)
+{
+	return sysctl_net_ll_poll;
+}
+
+/* a wrapper to make debug_smp_processor_id() happy
+ * we can use sched_clock() because we don't care much about precision
+ * we only care that the average is bounded
+ */
+#ifdef CONFIG_DEBUG_PREEMPT
+static inline u64 busy_loop_us_clock(void)
+{
+	u64 rc;
+
+	preempt_disable_notrace();
+	rc = sched_clock();
+	preempt_enable_no_resched_notrace();
+
+	return rc >> 10;
+}
+#else /* CONFIG_DEBUG_PREEMPT */
+static inline u64 busy_loop_us_clock(void)
+{
+	return sched_clock() >> 10;
+}
+#endif /* CONFIG_DEBUG_PREEMPT */
+
+static inline unsigned long sk_busy_loop_end_time(struct sock *sk)
+{
+	return busy_loop_us_clock() + ACCESS_ONCE(sk->sk_ll_usec);
+}
+
+/* in poll/select we use the global sysctl_net_ll_poll value */
+static inline unsigned long busy_loop_end_time(void)
+{
+	return busy_loop_us_clock() + ACCESS_ONCE(sysctl_net_ll_poll);
+}
+
+static inline bool sk_can_busy_loop(struct sock *sk)
+{
+	return sk->sk_ll_usec && sk->sk_napi_id &&
+	       !need_resched() && !signal_pending(current);
+}
+
+
+static inline bool busy_loop_timeout(unsigned long end_time)
+{
+	unsigned long now = busy_loop_us_clock();
+
+	return time_after(now, end_time);
+}
+
+/* when used in sock_poll() nonblock is known at compile time to be true
+ * so the loop and end_time will be optimized out
+ */
+static inline bool sk_busy_loop(struct sock *sk, int nonblock)
+{
+	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
+	const struct net_device_ops *ops;
+	struct napi_struct *napi;
+	int rc = false;
+
+	/*
+	 * rcu read lock for napi hash
+	 * bh so we don't race with net_rx_action
+	 */
+	rcu_read_lock_bh();
+
+	napi = napi_by_id(sk->sk_napi_id);
+	if (!napi)
+		goto out;
+
+	ops = napi->dev->netdev_ops;
+	if (!ops->ndo_ll_poll)
+		goto out;
+
+	do {
+		rc = ops->ndo_ll_poll(napi);
+
+		if (rc == LL_FLUSH_FAILED)
+			break; /* permanent failure */
+
+		if (rc > 0)
+			/* local bh are disabled so it is ok to use _BH */
+			NET_ADD_STATS_BH(sock_net(sk),
+					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
+
+	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
+		 !need_resched() && !busy_loop_timeout(end_time));
+
+	rc = !skb_queue_empty(&sk->sk_receive_queue);
+out:
+	rcu_read_unlock_bh();
+	return rc;
+}
+
+/* used in the NIC receive handler to mark the skb */
+static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+{
+	skb->napi_id = napi->napi_id;
+}
+
+/* used in the protocol hanlder to propagate the napi_id to the socket */
+static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+{
+	sk->sk_napi_id = skb->napi_id;
+}
+
+#else /* CONFIG_NET_LL_RX_POLL */
+static inline unsigned long net_busy_loop_on(void)
+{
+	return 0;
+}
+
+static inline unsigned long busy_loop_end_time(void)
+{
+	return 0;
+}
+
+static inline bool sk_can_busy_loop(struct sock *sk)
+{
+	return false;
+}
+
+static inline bool sk_busy_poll(struct sock *sk, int nonblock)
+{
+	return false;
+}
+
+static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
+{
+}
+
+static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
+{
+}
+
+static inline bool busy_loop_timeout(unsigned long end_time)
+{
+	return true;
+}
+
+#endif /* CONFIG_NET_LL_RX_POLL */
+#endif /* _LINUX_NET_LL_POLL_H */
diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
deleted file mode 100644
index 76f0340..0000000
--- a/include/net/ll_poll.h
+++ /dev/null
@@ -1,183 +0,0 @@
-/*
- * Low Latency Sockets
- * Copyright(c) 2013 Intel Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- *
- * This program is distributed in the hope it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
- *
- * Author: Eliezer Tamir
- *
- * Contact Information:
- * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
- */
-
-#ifndef _LINUX_NET_LL_POLL_H
-#define _LINUX_NET_LL_POLL_H
-
-#include <linux/netdevice.h>
-#include <net/ip.h>
-
-#ifdef CONFIG_NET_LL_RX_POLL
-
-struct napi_struct;
-extern unsigned int sysctl_net_ll_read __read_mostly;
-extern unsigned int sysctl_net_ll_poll __read_mostly;
-
-/* return values from ndo_ll_poll */
-#define LL_FLUSH_FAILED		-1
-#define LL_FLUSH_BUSY		-2
-
-static inline bool net_busy_loop_on(void)
-{
-	return sysctl_net_ll_poll;
-}
-
-/* a wrapper to make debug_smp_processor_id() happy
- * we can use sched_clock() because we don't care much about precision
- * we only care that the average is bounded
- */
-#ifdef CONFIG_DEBUG_PREEMPT
-static inline u64 busy_loop_us_clock(void)
-{
-	u64 rc;
-
-	preempt_disable_notrace();
-	rc = sched_clock();
-	preempt_enable_no_resched_notrace();
-
-	return rc >> 10;
-}
-#else /* CONFIG_DEBUG_PREEMPT */
-static inline u64 busy_loop_us_clock(void)
-{
-	return sched_clock() >> 10;
-}
-#endif /* CONFIG_DEBUG_PREEMPT */
-
-static inline unsigned long sk_busy_loop_end_time(struct sock *sk)
-{
-	return busy_loop_us_clock() + ACCESS_ONCE(sk->sk_ll_usec);
-}
-
-/* in poll/select we use the global sysctl_net_ll_poll value */
-static inline unsigned long busy_loop_end_time(void)
-{
-	return busy_loop_us_clock() + ACCESS_ONCE(sysctl_net_ll_poll);
-}
-
-static inline bool sk_can_busy_loop(struct sock *sk)
-{
-	return sk->sk_ll_usec && sk->sk_napi_id &&
-	       !need_resched() && !signal_pending(current);
-}
-
-
-static inline bool busy_loop_timeout(unsigned long end_time)
-{
-	unsigned long now = busy_loop_us_clock();
-
-	return time_after(now, end_time);
-}
-
-/* when used in sock_poll() nonblock is known at compile time to be true
- * so the loop and end_time will be optimized out
- */
-static inline bool sk_busy_loop(struct sock *sk, int nonblock)
-{
-	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
-	const struct net_device_ops *ops;
-	struct napi_struct *napi;
-	int rc = false;
-
-	/*
-	 * rcu read lock for napi hash
-	 * bh so we don't race with net_rx_action
-	 */
-	rcu_read_lock_bh();
-
-	napi = napi_by_id(sk->sk_napi_id);
-	if (!napi)
-		goto out;
-
-	ops = napi->dev->netdev_ops;
-	if (!ops->ndo_ll_poll)
-		goto out;
-
-	do {
-		rc = ops->ndo_ll_poll(napi);
-
-		if (rc == LL_FLUSH_FAILED)
-			break; /* permanent failure */
-
-		if (rc > 0)
-			/* local bh are disabled so it is ok to use _BH */
-			NET_ADD_STATS_BH(sock_net(sk),
-					 LINUX_MIB_LOWLATENCYRXPACKETS, rc);
-
-	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
-		 !need_resched() && !busy_loop_timeout(end_time));
-
-	rc = !skb_queue_empty(&sk->sk_receive_queue);
-out:
-	rcu_read_unlock_bh();
-	return rc;
-}
-
-/* used in the NIC receive handler to mark the skb */
-static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
-{
-	skb->napi_id = napi->napi_id;
-}
-
-/* used in the protocol hanlder to propagate the napi_id to the socket */
-static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
-{
-	sk->sk_napi_id = skb->napi_id;
-}
-
-#else /* CONFIG_NET_LL_RX_POLL */
-static inline unsigned long net_busy_loop_on(void)
-{
-	return 0;
-}
-
-static inline unsigned long busy_loop_end_time(void)
-{
-	return 0;
-}
-
-static inline bool sk_can_busy_loop(struct sock *sk)
-{
-	return false;
-}
-
-static inline bool sk_busy_poll(struct sock *sk, int nonblock)
-{
-	return false;
-}
-
-static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
-{
-}
-
-static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
-{
-}
-
-static inline bool busy_loop_timeout(unsigned long end_time)
-{
-	return true;
-}
-
-#endif /* CONFIG_NET_LL_RX_POLL */
-#endif /* _LINUX_NET_LL_POLL_H */
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 6e9ab31..8ab48cd 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -56,7 +56,7 @@
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <trace/events/skb.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 /*
  *	Is a socket 'connection oriented' ?
diff --git a/net/core/sock.c b/net/core/sock.c
index ab06b71..9bfe83f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -139,7 +139,7 @@
 #include <net/tcp.h>
 #endif
 
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 static DEFINE_MUTEX(proto_list_mutex);
 static LIST_HEAD(proto_list);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index afc677e..1a298cb 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -19,7 +19,7 @@
 #include <net/ip.h>
 #include <net/sock.h>
 #include <net/net_ratelimit.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 static int one = 1;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 15cbfa9..5423223 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -279,7 +279,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 35675e4..3a261b4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -75,7 +75,7 @@
 #include <net/netdma.h>
 #include <net/secure_seq.h>
 #include <net/tcp_memcontrol.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 #include <linux/inet.h>
 #include <linux/ipv6.h>
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6b270e5..bcc0ff2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -109,7 +109,7 @@
 #include <trace/events/udp.h>
 #include <linux/static_key.h>
 #include <trace/events/skb.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 #include "udp_impl.h"
 
 struct udp_table udp_table __read_mostly;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5cffa5c..345bd92 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -63,7 +63,7 @@
 #include <net/inet_common.h>
 #include <net/secure_seq.h>
 #include <net/tcp_memcontrol.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 #include <asm/uaccess.h>
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b6f3143..40e7203 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -46,7 +46,7 @@
 #include <net/ip6_checksum.h>
 #include <net/xfrm.h>
 #include <net/inet6_hashtables.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
diff --git a/net/socket.c b/net/socket.c
index 45afa64..6a3e9a3 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -104,7 +104,7 @@
 #include <linux/route.h>
 #include <linux/sockios.h>
 #include <linux/atalk.h>
-#include <net/ll_poll.h>
+#include <net/busy_poll.h>
 
 #ifdef CONFIG_NET_LL_RX_POLL
 unsigned int sysctl_net_ll_read __read_mostly;
