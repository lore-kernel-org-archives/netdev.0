From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] more network layer static funcs and data
Date: Thu, 29 Apr 2004 14:58:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040429145853.08c2ea8e@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Still more data structures and functions only referenced in the local file.

diff -Nru a/net/core/neighbour.c b/net/core/neighbour.c
--- a/net/core/neighbour.c	Thu Apr 29 14:46:31 2004
+++ b/net/core/neighbour.c	Thu Apr 29 14:46:31 2004
@@ -1479,7 +1479,7 @@
 
 #ifdef CONFIG_SYSCTL
 
-struct neigh_sysctl_table {
+static struct neigh_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	ctl_table		neigh_vars[17];
 	ctl_table		neigh_dev[2];
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Thu Apr 29 14:46:31 2004
+++ b/net/ipv4/route.c	Thu Apr 29 14:46:31 2004
@@ -144,7 +144,7 @@
 static int rt_garbage_collect(void);
 
 
-struct dst_ops ipv4_dst_ops = {
+static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		__constant_htons(ETH_P_IP),
 	.gc =			rt_garbage_collect,
@@ -1525,7 +1525,7 @@
  *	2. IP spoofing attempts are filtered with 100% of guarantee.
  */
 
-int ip_route_input_slow(struct sk_buff *skb, u32 daddr, u32 saddr,
+static int ip_route_input_slow(struct sk_buff *skb, u32 daddr, u32 saddr,
 			u8 tos, struct net_device *dev)
 {
 	struct fib_result res;
@@ -1910,7 +1910,7 @@
  * Major route resolver routine.
  */
 
-int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
+static int ip_route_output_slow(struct rtable **rp, const struct flowi *oldflp)
 {
 	u32 tos	= oldflp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK);
 	struct flowi fl = { .nl_u = { .ip4_u =
diff -Nru a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c	Thu Apr 29 14:46:31 2004
+++ b/net/ipv6/af_inet6.c	Thu Apr 29 14:46:31 2004
@@ -539,7 +539,7 @@
 	.sendpage =	sock_no_sendpage,
 };
 
-struct net_proto_family inet6_family_ops = {
+static struct net_proto_family inet6_family_ops = {
 	.family = PF_INET6,
 	.create = inet6_create,
 	.owner	= THIS_MODULE,
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	Thu Apr 29 14:46:31 2004
+++ b/net/ipv6/ndisc.c	Thu Apr 29 14:46:31 2004
@@ -1418,7 +1418,7 @@
 	return NOTIFY_DONE;
 }
 
-struct notifier_block ndisc_netdev_notifier = {
+static struct notifier_block ndisc_netdev_notifier = {
 	.notifier_call = ndisc_netdev_event,
 };
 
