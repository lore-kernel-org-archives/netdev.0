From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next v3 1/3] net: rename
 include/net/ll_poll.h to include/net/busy_poll.h
Date: Wed, 10 Jul 2013 17:13:17 +0300
Message-ID: <20130710141316.15596.61446.stgit@ladj378.jer.intel.com>
References: <20130710141307.15596.47242.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Jonathan Corbet <corbet@lwn.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Eilon Greenstein <eilong@broadcom.com>, Eric Dumazet <erdnetdev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130710141307.15596.47242.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

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
 
diff --git a/include/net/ll_poll.h b/include/net/busy_poll.h
similarity index 100%
rename from include/net/ll_poll.h
rename to include/net/busy_poll.h
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


------------------------------------------------------------------------------
See everything from the browser to the database with AppDynamics
Get end-to-end visibility with application monitoring from AppDynamics
Isolate bottlenecks and diagnose root cause in seconds.
Start your free trial of AppDynamics Pro today!
http://pubads.g.doubleclick.net/gampad/clk?id=48808831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
