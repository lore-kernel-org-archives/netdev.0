From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netlink functions that can be static (trivial)
Date: Wed, 28 Apr 2004 10:48:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040428104853.229f3d6c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several internal functions and tables in rtnetlink can be static, and
fill functions don't change stat of the net_device.

diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	Wed Apr 28 10:44:47 2004
+++ b/net/core/rtnetlink.c	Wed Apr 28 10:44:47 2004
@@ -153,7 +153,8 @@
 }
 
 
-static int rtnetlink_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
+static int rtnetlink_fill_ifinfo(struct sk_buff *skb,
+				 const struct net_device *dev,
 				 int type, u32 pid, u32 seq, u32 change)
 {
 	struct ifinfomsg *r;
@@ -214,11 +215,11 @@
 	return -1;
 }
 
-int rtnetlink_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+static int rtnetlink_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->args[0];
-	struct net_device *dev;
+	const struct net_device *dev;
 
 	read_lock(&dev_base_lock);
 	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
@@ -280,7 +281,7 @@
 	return err;
 }
 
-int rtnetlink_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
+static int rtnetlink_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->family;
@@ -553,7 +554,7 @@
 	return NOTIFY_DONE;
 }
 
-struct notifier_block rtnetlink_dev_notifier = {
+static struct notifier_block rtnetlink_dev_notifier = {
 	.notifier_call	= rtnetlink_event,
 };
 
diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	Wed Apr 28 10:44:47 2004
+++ b/net/netlink/af_netlink.c	Wed Apr 28 10:44:47 2004
@@ -809,7 +809,7 @@
 	return err ? : copied;
 }
 
-void netlink_data_ready(struct sock *sk, int len)
+static void netlink_data_ready(struct sock *sk, int len)
 {
 	struct netlink_opt *nlk = nlk_sk(sk);
 
@@ -1126,7 +1126,7 @@
 	return 0;
 }
 
-struct seq_operations netlink_seq_ops = {
+static struct seq_operations netlink_seq_ops = {
 	.start  = netlink_seq_start,
 	.next   = netlink_seq_next,
 	.stop   = netlink_seq_stop,
@@ -1159,7 +1159,7 @@
 	return notifier_chain_unregister(&netlink_chain, nb);
 }
                 
-struct proto_ops netlink_ops = {
+static struct proto_ops netlink_ops = {
 	.family =	PF_NETLINK,
 	.owner =	THIS_MODULE,
 	.release =	netlink_release,
@@ -1180,7 +1180,7 @@
 	.sendpage =	sock_no_sendpage,
 };
 
-struct net_proto_family netlink_family_ops = {
+static struct net_proto_family netlink_family_ops = {
 	.family = PF_NETLINK,
 	.create = netlink_create,
 	.owner	= THIS_MODULE,	/* for consistency 8) */
