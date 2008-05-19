From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 3/6][FRAGS]: Rename sysctl-related functions/variables.
Date: Mon, 19 May 2008 19:58:40 +0400
Message-ID: <4831A3B0.80301@openvz.org>
References: <4831A1D6.4090503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60568 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991AbYESQBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 12:01:07 -0400
In-Reply-To: <4831A1D6.4090503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fragments sysctls also contains some, that are to be
visible, but read-only in net namespaces.

The naming in net/core/sysctl_net_core.c is - tables, that are
to be registered in namespaces have a "ns" word in their names.
So rename ones in ipv4/ip_fragment.c and ipv6/reassembly.c to
fit this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_fragment.c |   18 +++++++++---------
 net/ipv6/reassembly.c  |   18 +++++++++---------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index cd6ce6a..7f102ee 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -598,7 +598,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 #ifdef CONFIG_SYSCTL
 static int zero;
 
-static struct ctl_table ip4_frags_ctl_table[] = {
+static struct ctl_table ip4_frags_ns_ctl_table[] = {
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_HIGH_THRESH,
 		.procname	= "ipfrag_high_thresh",
@@ -644,14 +644,14 @@ static struct ctl_table ip4_frags_ctl_table[] = {
 	{ }
 };
 
-static int ip4_frags_ctl_register(struct net *net)
+static int ip4_frags_ns_ctl_register(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
 
-	table = ip4_frags_ctl_table;
+	table = ip4_frags_ns_ctl_table;
 	if (net != &init_net) {
-		table = kmemdup(table, sizeof(ip4_frags_ctl_table), GFP_KERNEL);
+		table = kmemdup(table, sizeof(ip4_frags_ns_ctl_table), GFP_KERNEL);
 		if (table == NULL)
 			goto err_alloc;
 
@@ -676,7 +676,7 @@ err_alloc:
 	return -ENOMEM;
 }
 
-static void ip4_frags_ctl_unregister(struct net *net)
+static void ip4_frags_ns_ctl_unregister(struct net *net)
 {
 	struct ctl_table *table;
 
@@ -685,12 +685,12 @@ static void ip4_frags_ctl_unregister(struct net *net)
 	kfree(table);
 }
 #else
-static inline int ip4_frags_ctl_register(struct net *net)
+static inline int ip4_frags_ns_ctl_register(struct net *net)
 {
 	return 0;
 }
 
-static inline void ip4_frags_ctl_unregister(struct net *net)
+static inline void ip4_frags_ns_ctl_unregister(struct net *net)
 {
 }
 #endif
@@ -714,12 +714,12 @@ static int ipv4_frags_init_net(struct net *net)
 
 	inet_frags_init_net(&net->ipv4.frags);
 
-	return ip4_frags_ctl_register(net);
+	return ip4_frags_ns_ctl_register(net);
 }
 
 static void ipv4_frags_exit_net(struct net *net)
 {
-	ip4_frags_ctl_unregister(net);
+	ip4_frags_ns_ctl_unregister(net);
 	inet_frags_exit_net(&net->ipv4.frags, &ip4_frags);
 }
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 798cabc..7e008de 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -632,7 +632,7 @@ static struct inet6_protocol frag_protocol =
 };
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_table ip6_frags_ctl_table[] = {
+static struct ctl_table ip6_frags_ns_ctl_table[] = {
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_HIGH_THRESH,
 		.procname	= "ip6frag_high_thresh",
@@ -670,14 +670,14 @@ static struct ctl_table ip6_frags_ctl_table[] = {
 	{ }
 };
 
-static int ip6_frags_sysctl_register(struct net *net)
+static int ip6_frags_ns_sysctl_register(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
 
-	table = ip6_frags_ctl_table;
+	table = ip6_frags_ns_ctl_table;
 	if (net != &init_net) {
-		table = kmemdup(table, sizeof(ip6_frags_ctl_table), GFP_KERNEL);
+		table = kmemdup(table, sizeof(ip6_frags_ns_ctl_table), GFP_KERNEL);
 		if (table == NULL)
 			goto err_alloc;
 
@@ -701,7 +701,7 @@ err_alloc:
 	return -ENOMEM;
 }
 
-static void ip6_frags_sysctl_unregister(struct net *net)
+static void ip6_frags_ns_sysctl_unregister(struct net *net)
 {
 	struct ctl_table *table;
 
@@ -710,12 +710,12 @@ static void ip6_frags_sysctl_unregister(struct net *net)
 	kfree(table);
 }
 #else
-static inline int ip6_frags_sysctl_register(struct net *net)
+static inline int ip6_frags_ns_sysctl_register(struct net *net)
 {
 	return 0;
 }
 
-static inline void ip6_frags_sysctl_unregister(struct net *net)
+static inline void ip6_frags_ns_sysctl_unregister(struct net *net)
 {
 }
 #endif
@@ -728,12 +728,12 @@ static int ipv6_frags_init_net(struct net *net)
 
 	inet_frags_init_net(&net->ipv6.frags);
 
-	return ip6_frags_sysctl_register(net);
+	return ip6_frags_ns_sysctl_register(net);
 }
 
 static void ipv6_frags_exit_net(struct net *net)
 {
-	ip6_frags_sysctl_unregister(net);
+	ip6_frags_ns_sysctl_unregister(net);
 	inet_frags_exit_net(&net->ipv6.frags, &ip6_frags);
 }
 
-- 
1.5.3.4

