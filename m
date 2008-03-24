From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/5][NETNS][UDP-Lite]: Register /proc/net/udplite(6)
 in a namespace.
Date: Mon, 24 Mar 2008 13:53:01 +0300
Message-ID: <47E7880D.8000501@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53190 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756968AbYCXKxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 06:53:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP-Lite sockets are displayed in another files, rather than
UDP ones, so make the present in namespaces as well.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/udplite.c |   17 ++++++++++++++++-
 net/ipv6/udplite.c |   19 +++++++++++++++++--
 2 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 653a6fc..9ee1d15 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -83,9 +83,24 @@ static struct udp_seq_afinfo udplite4_seq_afinfo = {
 	.seq_fops	= &udplite4_seq_fops,
 };
 
+static int udplite4_proc_init_net(struct net *net)
+{
+	return udp_proc_register(net, &udplite4_seq_afinfo);
+}
+
+static void udplite4_proc_exit_net(struct net *net)
+{
+	udp_proc_unregister(net, &udplite4_seq_afinfo);
+}
+
+static struct pernet_operations udplite4_net_ops = {
+	.init = udplite4_proc_init_net,
+	.exit = udplite4_proc_exit_net,
+};
+
 static __init int udplite4_proc_init(void)
 {
-	return udp_proc_register(&init_net, &udplite4_seq_afinfo);
+	return register_pernet_subsys(&udplite4_net_ops);
 }
 #else
 static inline int udplite4_proc_init(void)
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 93e52e0..706c5c3 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -109,13 +109,28 @@ static struct udp_seq_afinfo udplite6_seq_afinfo = {
 	.seq_fops	= &udplite6_seq_fops,
 };
 
+static int udplite6_proc_init_net(struct net *net)
+{
+	return udp_proc_register(net, &udplite6_seq_afinfo);
+}
+
+static void udplite6_proc_exit_net(struct net *net)
+{
+	udp_proc_unregister(net, &udplite6_seq_afinfo);
+}
+
+static struct pernet_operations udplite6_net_ops = {
+	.init = udplite6_proc_init_net,
+	.exit = udplite6_proc_exit_net,
+};
+
 int __init udplite6_proc_init(void)
 {
-	return udp_proc_register(&init_net, &udplite6_seq_afinfo);
+	return register_pernet_subsys(&udplite6_net_ops);
 }
 
 void udplite6_proc_exit(void)
 {
-	udp_proc_unregister(&init_net, &udplite6_seq_afinfo);
+	unregister_pernet_subsys(&udplite6_net_ops);
 }
 #endif
-- 
1.5.3.4

