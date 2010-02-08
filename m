From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/05: xtables: compat out of scope fix
Date: Mon,  8 Feb 2010 18:10:31 +0100 (MET)
Message-ID: <20100208171029.15522.33495.sendpatchset@x2.localnet>
References: <20100208171024.15522.8136.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100208171024.15522.8136.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit dab1531a07ad7c5be4ebe715a3d08742f0c638e3
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Feb 8 15:44:07 2010 +0100

    netfilter: xtables: compat out of scope fix
    
    As per C99 6.2.4(2) when temporary table data goes out of scope,
    the behaviour is undefined:
    
    	if (compat) {
    		struct foo tmp;
    		...
    		private = &tmp;
    	}
    	[dereference private]
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Cc: stable@kernel.org
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 0663276..90203e1 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -925,10 +925,10 @@ static int get_info(struct net *net, void __user *user, int *len, int compat)
 	if (t && !IS_ERR(t)) {
 		struct arpt_getinfo info;
 		const struct xt_table_info *private = t->private;
-
 #ifdef CONFIG_COMPAT
+		struct xt_table_info tmp;
+
 		if (compat) {
-			struct xt_table_info tmp;
 			ret = compat_table_info(private, &tmp);
 			xt_compat_flush_offsets(NFPROTO_ARP);
 			private = &tmp;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 572330a..3ce53cf 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1132,10 +1132,10 @@ static int get_info(struct net *net, void __user *user, int *len, int compat)
 	if (t && !IS_ERR(t)) {
 		struct ipt_getinfo info;
 		const struct xt_table_info *private = t->private;
-
 #ifdef CONFIG_COMPAT
+		struct xt_table_info tmp;
+
 		if (compat) {
-			struct xt_table_info tmp;
 			ret = compat_table_info(private, &tmp);
 			xt_compat_flush_offsets(AF_INET);
 			private = &tmp;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 480d7f8..8a7e0f5 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1164,10 +1164,10 @@ static int get_info(struct net *net, void __user *user, int *len, int compat)
 	if (t && !IS_ERR(t)) {
 		struct ip6t_getinfo info;
 		const struct xt_table_info *private = t->private;
-
 #ifdef CONFIG_COMPAT
+		struct xt_table_info tmp;
+
 		if (compat) {
-			struct xt_table_info tmp;
 			ret = compat_table_info(private, &tmp);
 			xt_compat_flush_offsets(AF_INET6);
 			private = &tmp;
