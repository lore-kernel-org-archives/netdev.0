From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/08: remove unneccessary checks from netlink notifiers
Date: Thu,  3 Dec 2009 21:19:38 +0100 (MET)
Message-ID: <20091203201938.8831.59754.sendpatchset@x2.localnet>
References: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit dee5817e88ac8195e5938d6671f434a071e35698
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Nov 6 17:04:00 2009 +0100

    netfilter: remove unneccessary checks from netlink notifiers
    
    The NETLINK_URELEASE notifier is only invoked for bound sockets, so
    there is no need to check ->pid again.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 9811a45..9f07870 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -497,8 +497,7 @@ ipq_rcv_nl_event(struct notifier_block *this,
 {
 	struct netlink_notify *n = ptr;
 
-	if (event == NETLINK_URELEASE &&
-	    n->protocol == NETLINK_FIREWALL && n->pid) {
+	if (event == NETLINK_URELEASE && n->protocol == NETLINK_FIREWALL) {
 		write_lock_bh(&queue_lock);
 		if ((n->net == &init_net) && (n->pid == peer_pid))
 			__ipq_reset();
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index a82016f..47a3623 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -499,8 +499,7 @@ ipq_rcv_nl_event(struct notifier_block *this,
 {
 	struct netlink_notify *n = ptr;
 
-	if (event == NETLINK_URELEASE &&
-	    n->protocol == NETLINK_IP6_FW && n->pid) {
+	if (event == NETLINK_URELEASE && n->protocol == NETLINK_IP6_FW) {
 		write_lock_bh(&queue_lock);
 		if ((n->net == &init_net) && (n->pid == peer_pid))
 			__ipq_reset();
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index f900dc3..3aa66b2 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -666,8 +666,7 @@ nfulnl_rcv_nl_event(struct notifier_block *this,
 {
 	struct netlink_notify *n = ptr;
 
-	if (event == NETLINK_URELEASE &&
-	    n->protocol == NETLINK_NETFILTER && n->pid) {
+	if (event == NETLINK_URELEASE && n->protocol == NETLINK_NETFILTER) {
 		int i;
 
 		/* destroy all instances for this pid */
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7a9dec9..7e3fa41 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -574,8 +574,7 @@ nfqnl_rcv_nl_event(struct notifier_block *this,
 {
 	struct netlink_notify *n = ptr;
 
-	if (event == NETLINK_URELEASE &&
-	    n->protocol == NETLINK_NETFILTER && n->pid) {
+	if (event == NETLINK_URELEASE && n->protocol == NETLINK_NETFILTER) {
 		int i;
 
 		/* destroy all instances for this pid */
