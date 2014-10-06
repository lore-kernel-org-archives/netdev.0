From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: core: Quiet W=1 warnings for unused vars and
 static functions
Date: Mon, 06 Oct 2014 14:51:38 -0700
Message-ID: <1412632298.2916.42.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce noise when compiling W=1.

All the variables are unused.
The functions are not called outside of the file so static
is preferred.

Signed-off-by: Joe Perches <joe@perches.com>
---

John, can you please verify that these gen_stats accesses
are unnecessary?  I believe the compiler can elide them in
any case, but I'm not sure what you intended here.

 net/core/dev.c       | 4 ++--
 net/core/gen_stats.c | 4 ----
 net/core/rtnetlink.c | 3 +--
 3 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1a90530..2049a17 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5239,7 +5239,7 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
-void netdev_adjacent_add_links(struct net_device *dev)
+static void netdev_adjacent_add_links(struct net_device *dev)
 {
 	struct netdev_adjacent *iter;
 
@@ -5264,7 +5264,7 @@ void netdev_adjacent_add_links(struct net_device *dev)
 	}
 }
 
-void netdev_adjacent_del_links(struct net_device *dev)
+static void netdev_adjacent_del_links(struct net_device *dev)
 {
 	struct netdev_adjacent *iter;
 
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 14681b9..01be9cf 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -106,13 +106,9 @@ __gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
 	for_each_possible_cpu(i) {
 		struct gnet_stats_basic_cpu *bcpu = per_cpu_ptr(cpu, i);
 		unsigned int start;
-		__u64 bytes;
-		__u32 packets;
 
 		do {
 			start = u64_stats_fetch_begin_irq(&bcpu->syncp);
-			bytes = bcpu->bstats.bytes;
-			packets = bcpu->bstats.packets;
 		} while (u64_stats_fetch_retry_irq(&bcpu->syncp, start));
 
 		bstats->bytes += bcpu->bstats.bytes;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a688268..c2fe350 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2917,7 +2917,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	rtnl_doit_func doit;
-	int sz_idx, kind;
+	int kind;
 	int family;
 	int type;
 	int err;
@@ -2933,7 +2933,6 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return 0;
 
 	family = ((struct rtgenmsg *)nlmsg_data(nlh))->rtgen_family;
-	sz_idx = type>>2;
 	kind = type&3;
 
 	if (kind != 2 && !netlink_net_capable(skb, CAP_NET_ADMIN))
