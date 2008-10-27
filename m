From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 09/09]IPtablestng/KernelSpace - patch extensions modules
Date: Mon, 27 Oct 2008 08:30:10 +0330 (IRST)
Message-ID: <20081027050010.7A208C64091@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use 'pktt_entry' instead of 'ipt_entry'.

some changes in some extensions for campatibility.

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index a12dd32..9f57c26 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -367,35 +367,35 @@ clusterip_tg_check(const char *tablename, const void *e_void,
 		return false;
 
 	}
-	if (e->ip.dmsk.s_addr != htonl(0xffffffff)
-	    || e->ip.dst.s_addr == 0) {
+	if (e->pkt_header.ip4.dmsk.s_addr != htonl(0xffffffff)
+	    || e->pkt_header.ip4.dst.s_addr == 0) {
 		printk(KERN_ERR "CLUSTERIP: Please specify destination IP\n");
 		return false;
 	}
 
 	/* FIXME: further sanity checks */
 
-	config = clusterip_config_find_get(e->ip.dst.s_addr, 1);
+	config = clusterip_config_find_get(e->pkt_header.ip4.dst.s_addr, 1);
 	if (!config) {
 		if (!(cipinfo->flags & CLUSTERIP_FLAG_NEW)) {
-			printk(KERN_WARNING "CLUSTERIP: no config found for %u.%u.%u.%u, need 'new'\n", NIPQUAD(e->ip.dst.s_addr));
+			printk(KERN_WARNING "CLUSTERIP: no config found for %u.%u.%u.%u, need 'new'\n", NIPQUAD(e->pkt_header.ip4.dst.s_addr));
 			return false;
 		} else {
 			struct net_device *dev;
 
-			if (e->ip.iniface[0] == '\0') {
+			if (e->pkt_header.ip4.iniface[0] == '\0') {
 				printk(KERN_WARNING "CLUSTERIP: Please specify an interface name\n");
 				return false;
 			}
 
-			dev = dev_get_by_name(&init_net, e->ip.iniface);
+			dev = dev_get_by_name(&init_net, e->pkt_header.ip4.iniface);
 			if (!dev) {
-				printk(KERN_WARNING "CLUSTERIP: no such interface %s\n", e->ip.iniface);
+				printk(KERN_WARNING "CLUSTERIP: no such interface %s\n", e->pkt_header.ip4.iniface);
 				return false;
 			}
 
 			config = clusterip_config_init(cipinfo,
-							e->ip.dst.s_addr, dev);
+							e->pkt_header.ip4.dst.s_addr, dev);
 			if (!config) {
 				printk(KERN_WARNING "CLUSTERIP: cannot allocate config\n");
 				dev_put(dev);
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 21395bc..41f8650 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -114,7 +114,7 @@ ecn_tg_check(const char *tablename, const void *e_void,
 		return false;
 	}
 	if ((einfo->operation & (IPT_ECN_OP_SET_ECE|IPT_ECN_OP_SET_CWR))
-	    && (e->ip.proto != IPPROTO_TCP || (e->ip.invflags & XT_INV_PROTO))) {
+	    && (e->pkt_header.ip4.proto != IPPROTO_TCP || (e->pkt_header.ip4.invflags & XT_INV_PROTO))) {
 		printk(KERN_WARNING "ECN: cannot use TCP operations on a "
 		       "non-tcp rule\n");
 		return false;
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 22606e2..0a851ea 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -188,8 +188,8 @@ reject_tg_check(const char *tablename, const void *e_void,
 		return false;
 	} else if (rejinfo->with == IPT_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
-		if (e->ip.proto != IPPROTO_TCP
-		    || (e->ip.invflags & XT_INV_PROTO)) {
+		if (e->pkt_header.ip4.proto != IPPROTO_TCP
+		    || (e->pkt_header.ip4.invflags & XT_INV_PROTO)) {
 			printk("ipt_REJECT: TCP_RESET invalid for non-tcp\n");
 			return false;
 		}

