From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netlink functions that can be static (trivial)
Date: Wed, 28 Apr 2004 15:02:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040428150216.7e7c1432@dell_ss3.pdx.osdl.net>
References: <20040428104853.229f3d6c@dell_ss3.pdx.osdl.net>
	<20040428122535.4f30f1b0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040428122535.4f30f1b0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Actually it is dump_ifinfo that's exported.. here is a fixed patch.

diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	Wed Apr 28 15:00:34 2004
+++ b/net/core/rtnetlink.c	Wed Apr 28 15:00:34 2004
@@ -280,7 +280,7 @@
 	return err;
 }
 
-int rtnetlink_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
+static int rtnetlink_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->family;
@@ -553,7 +553,7 @@
 	return NOTIFY_DONE;
 }
 
-struct notifier_block rtnetlink_dev_notifier = {
+static struct notifier_block rtnetlink_dev_notifier = {
 	.notifier_call	= rtnetlink_event,
 };
 
diff -Nru a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	Wed Apr 28 15:00:34 2004
+++ b/net/netlink/af_netlink.c	Wed Apr 28 15:00:34 2004
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
