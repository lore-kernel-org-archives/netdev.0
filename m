From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] net/netfilter: Convert printk uses to pr_<level>
Date: Thu, 11 Jun 2009 00:40:21 -0700
Message-ID: <835d5482f92aa00f571b2775b96e0e555c31bcf8.1244705154.git.joe@perches.com>
References: <cover.1244705154.git.joe@perches.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3305 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757988AbZFKHkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 03:40:37 -0400
In-Reply-To: <cover.1244705154.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove function names from format strings
Add #define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/nf_conntrack_acct.c       |   12 ++-
 net/netfilter/nf_conntrack_amanda.c     |    5 +-
 net/netfilter/nf_conntrack_core.c       |   43 +++++------
 net/netfilter/nf_conntrack_expect.c     |    5 +-
 net/netfilter/nf_conntrack_ftp.c        |   46 ++++++------
 net/netfilter/nf_conntrack_h323_main.c  |  123 +++++++++++++++----------------
 net/netfilter/nf_conntrack_helper.c     |    2 +
 net/netfilter/nf_conntrack_irc.c        |   16 ++--
 net/netfilter/nf_conntrack_netlink.c    |   14 ++--
 net/netfilter/nf_conntrack_pptp.c       |    2 +
 net/netfilter/nf_conntrack_proto_gre.c  |    2 +
 net/netfilter/nf_conntrack_proto_sctp.c |    6 +-
 net/netfilter/nf_conntrack_proto_tcp.c  |   28 ++++---
 net/netfilter/nf_conntrack_sane.c       |   20 +++---
 net/netfilter/nf_conntrack_sip.c        |   10 ++-
 net/netfilter/nf_conntrack_standalone.c |    4 +-
 net/netfilter/nf_conntrack_tftp.c       |    6 +-
 net/netfilter/nf_tproxy_core.c          |    2 +
 net/netfilter/nfnetlink.c               |    8 +-
 net/netfilter/nfnetlink_log.c           |    9 ++-
 net/netfilter/nfnetlink_queue.c         |   18 +++--
 net/netfilter/xt_CONNMARK.c             |   18 +++--
 net/netfilter/xt_CONNSECMARK.c          |   13 ++-
 net/netfilter/xt_DSCP.c                 |    6 +-
 net/netfilter/xt_HL.c                   |   11 +--
 net/netfilter/xt_LED.c                  |   12 ++--
 net/netfilter/xt_MARK.c                 |    9 +-
 net/netfilter/xt_SECMARK.c              |   23 +++---
 net/netfilter/xt_TCPMSS.c               |   22 +++---
 net/netfilter/xt_cluster.c              |   11 ++-
 net/netfilter/xt_connbytes.c            |    7 +-
 net/netfilter/xt_connlimit.c            |    7 +-
 net/netfilter/xt_connmark.c             |   12 ++-
 net/netfilter/xt_conntrack.c            |    6 +-
 net/netfilter/xt_dscp.c                 |    4 +-
 net/netfilter/xt_hashlimit.c            |   27 +++----
 net/netfilter/xt_helper.c               |    6 +-
 net/netfilter/xt_hl.c                   |    8 +-
 net/netfilter/xt_iprange.c              |    3 +
 net/netfilter/xt_limit.c                |    6 +-
 net/netfilter/xt_mark.c                 |    4 +-
 net/netfilter/xt_osf.c                  |    8 +-
 net/netfilter/xt_owner.c                |   10 +-
 net/netfilter/xt_physdev.c              |    8 +-
 net/netfilter/xt_policy.c               |   13 ++--
 net/netfilter/xt_recent.c               |   12 ++-
 net/netfilter/xt_socket.c               |    5 +-
 net/netfilter/xt_state.c                |    6 +-
 net/netfilter/xt_statistic.c            |    4 +-
 net/netfilter/xt_time.c                 |   16 ++--
 50 files changed, 375 insertions(+), 303 deletions(-)

diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 4a1d94a..50ddb7f 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -8,6 +8,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/netfilter.h>
 #include <linux/kernel.h>
 #include <linux/moduleparam.h>
@@ -77,7 +79,7 @@ static int nf_conntrack_acct_init_sysctl(struct net *net)
 	net->ct.acct_sysctl_header = register_net_sysctl_table(net,
 			nf_net_netfilter_sysctl_path, table);
 	if (!net->ct.acct_sysctl_header) {
-		printk(KERN_ERR "nf_conntrack_acct: can't register to sysctl.\n");
+		pr_err("can't register to sysctl.\n");
 		goto out_register;
 	}
 	return 0;
@@ -115,14 +117,14 @@ int nf_conntrack_acct_init(struct net *net)
 
 	if (net_eq(net, &init_net)) {
 #ifdef CONFIG_NF_CT_ACCT
-	printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use\n");
-		printk(KERN_WARNING "nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or\n");
-		printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
+		pr_warning("CONFIG_NF_CT_ACCT is deprecated and will be removed soon.\n");
+		pr_warning("Please use nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack\n");
+		pr_warning("module option or sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
 #endif
 
 		ret = nf_ct_extend_register(&acct_extend);
 		if (ret < 0) {
-			printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
+			pr_err("Unable to register extension\n");
 			goto out_extend_register;
 		}
 	}
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 07d9d88..0696fa0 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -8,6 +8,9 @@
  * as published by the Free Software Foundation; either version
  * 2 of the License, or (at your option) any later version.
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -107,7 +110,7 @@ static int amanda_help(struct sk_buff *skb,
 	dataoff = protoff + sizeof(struct udphdr);
 	if (dataoff >= skb->len) {
 		if (net_ratelimit())
-			printk("amanda_help: skblen = %u\n", skb->len);
+			pr_info("skblen = %u\n", skb->len);
 		return NF_ACCEPT;
 	}
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index edf9569..41b2603 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -11,6 +11,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/types.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
@@ -163,7 +165,7 @@ EXPORT_SYMBOL_GPL(nf_ct_invert_tuple);
 static void
 clean_from_lists(struct nf_conn *ct)
 {
-	pr_debug("clean_from_lists(%p)\n", ct);
+	pr_debug("(%p)\n", ct);
 	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode);
 
@@ -178,7 +180,7 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_l4proto *l4proto;
 
-	pr_debug("destroy_conntrack(%p)\n", ct);
+	pr_debug("(%p)\n", ct);
 	NF_CT_ASSERT(atomic_read(&nfct->use) == 0);
 	NF_CT_ASSERT(!timer_pending(&ct->timeout));
 
@@ -215,7 +217,7 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	if (ct->master)
 		nf_ct_put(ct->master);
 
-	pr_debug("destroy_conntrack: returning ct=%p to slab\n", ct);
+	pr_debug("returning ct=%p to slab\n", ct);
 	nf_conntrack_free(ct);
 }
 
@@ -505,16 +507,14 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
 			if (net_ratelimit())
-				printk(KERN_WARNING
-				       "nf_conntrack: table full, dropping"
-				       " packet.\n");
+				pr_warning("table full, dropping packet.\n");
 			return ERR_PTR(-ENOMEM);
 		}
 	}
 
 	ct = kmem_cache_zalloc(nf_conntrack_cachep, gfp);
 	if (ct == NULL) {
-		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
+		pr_debug("Can't alloc conntrack.\n");
 		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
@@ -572,7 +572,7 @@ init_conntrack(struct net *net,
 
 	if (!l4proto->new(ct, skb, dataoff)) {
 		nf_conntrack_free(ct);
-		pr_debug("init conntrack: can't track with proto module\n");
+		pr_debug("can't track with proto module\n");
 		return NULL;
 	}
 
@@ -581,7 +581,7 @@ init_conntrack(struct net *net,
 	spin_lock_bh(&nf_conntrack_lock);
 	exp = nf_ct_find_expectation(net, tuple);
 	if (exp) {
-		pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
+		pr_debug("expectation arrives ct=%p exp=%p\n",
 			 ct, exp);
 		/* Welcome, Mr. Bond.  We've been expecting you... */
 		__set_bit(IPS_EXPECTED_BIT, &ct->status);
@@ -639,7 +639,7 @@ resolve_normal_ct(struct net *net,
 	if (!nf_ct_get_tuple(skb, skb_network_offset(skb),
 			     dataoff, l3num, protonum, &tuple, l3proto,
 			     l4proto)) {
-		pr_debug("resolve_normal_ct: Can't get tuple\n");
+		pr_debug("Can't get tuple\n");
 		return NULL;
 	}
 
@@ -662,14 +662,13 @@ resolve_normal_ct(struct net *net,
 	} else {
 		/* Once we've had two way comms, always ESTABLISHED. */
 		if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
-			pr_debug("nf_conntrack_in: normal packet for %p\n", ct);
+			pr_debug("normal packet for %p\n", ct);
 			*ctinfo = IP_CT_ESTABLISHED;
 		} else if (test_bit(IPS_EXPECTED_BIT, &ct->status)) {
-			pr_debug("nf_conntrack_in: related packet for %p\n",
-				 ct);
+			pr_debug("related packet for %p\n", ct);
 			*ctinfo = IP_CT_RELATED;
 		} else {
-			pr_debug("nf_conntrack_in: new packet for %p\n", ct);
+			pr_debug("new packet for %p\n", ct);
 			*ctinfo = IP_CT_NEW;
 		}
 		*set_reply = 0;
@@ -703,7 +702,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	ret = l3proto->get_l4proto(skb, skb_network_offset(skb),
 				   &dataoff, &protonum);
 	if (ret <= 0) {
-		pr_debug("not prepared to track yet or error occured\n");
+		pr_debug("not prepared to track yet or error occurred\n");
 		NF_CT_STAT_INC_ATOMIC(net, error);
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		return -ret;
@@ -743,7 +742,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	if (ret <= 0) {
 		/* Invalid: inverse of the return code tells
 		 * the netfilter core what to do */
-		pr_debug("nf_conntrack_in: Can't track with proto module\n");
+		pr_debug("Can't track with proto module\n");
 		nf_conntrack_put(skb->nfct);
 		skb->nfct = NULL;
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
@@ -1090,7 +1089,7 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int nulls)
 					get_order(sz));
 	if (!hash) {
 		*vmalloced = 1;
-		printk(KERN_WARNING "nf_conntrack: falling back to vmalloc.\n");
+		pr_warning("falling back to vmalloc.\n");
 		hash = __vmalloc(sz, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	}
 
@@ -1183,15 +1182,15 @@ static int nf_conntrack_init_init_net(void)
 	}
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
-	printk("nf_conntrack version %s (%u buckets, %d max)\n",
-	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
-	       nf_conntrack_max);
+	pr_info("nf_conntrack version %s (%u buckets, %d max)\n",
+		NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
+		nf_conntrack_max);
 
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
 						0, SLAB_DESTROY_BY_RCU, NULL);
 	if (!nf_conntrack_cachep) {
-		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
+		pr_err("Unable to create nf_conn slab cache\n");
 		ret = -ENOMEM;
 		goto err_cache;
 	}
@@ -1232,7 +1231,7 @@ static int nf_conntrack_init_net(struct net *net)
 					     &net->ct.hash_vmalloc, 1);
 	if (!net->ct.hash) {
 		ret = -ENOMEM;
-		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
+		pr_err("Unable to create nf_conntrack_hash\n");
 		goto err_hash;
 	}
 	ret = nf_conntrack_expect_init(net);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index afde8f9..d2332c1 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -9,6 +9,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/types.h>
 #include <linux/netfilter.h>
 #include <linux/skbuff.h>
@@ -404,8 +406,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 
 	if (net->ct.expect_count >= nf_ct_expect_max) {
 		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "nf_conntrack: expectation table full\n");
+			pr_warning("expectation table full\n");
 		ret = -EMFILE;
 	}
 out:
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 5509dd1..1e883fa 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -9,6 +9,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/netfilter.h>
@@ -173,13 +175,13 @@ static int get_port(const char *data, int start, size_t dlen, char delim,
 			if (tmp_port == 0)
 				break;
 			*port = htons(tmp_port);
-			pr_debug("get_port: return %d\n", tmp_port);
+			pr_debug("return %d\n", tmp_port);
 			return i + 1;
 		}
 		else if (data[i] >= '0' && data[i] <= '9')
 			tmp_port = tmp_port*10 + data[i] - '0';
 		else { /* Some other crap */
-			pr_debug("get_port: invalid char.\n");
+			pr_debug("invalid char.\n");
 			break;
 		}
 	}
@@ -196,22 +198,22 @@ static int try_eprt(const char *data, size_t dlen, struct nf_conntrack_man *cmd,
 	/* First character is delimiter, then "1" for IPv4 or "2" for IPv6,
 	   then delimiter again. */
 	if (dlen <= 3) {
-		pr_debug("EPRT: too short\n");
+		pr_debug("too short\n");
 		return 0;
 	}
 	delim = data[0];
 	if (isdigit(delim) || delim < 33 || delim > 126 || data[2] != delim) {
-		pr_debug("try_eprt: invalid delimitter.\n");
+		pr_debug("invalid delimiter.\n");
 		return 0;
 	}
 
 	if ((cmd->l3num == PF_INET && data[1] != '1') ||
 	    (cmd->l3num == PF_INET6 && data[1] != '2')) {
-		pr_debug("EPRT: invalid protocol number.\n");
+		pr_debug("invalid protocol number.\n");
 		return 0;
 	}
 
-	pr_debug("EPRT: Got %c%c%c\n", delim, data[1], delim);
+	pr_debug("Got %c%c%c\n", delim, data[1], delim);
 
 	if (data[1] == '1') {
 		u_int32_t array[4];
@@ -229,7 +231,7 @@ static int try_eprt(const char *data, size_t dlen, struct nf_conntrack_man *cmd,
 
 	if (length == 0)
 		return 0;
-	pr_debug("EPRT: Got IP address!\n");
+	pr_debug("Got IP address!\n");
 	/* Start offset includes initial "|1|", and trailing delimiter */
 	return get_port(data, 3 + length + 1, dlen, delim, &cmd->u.tcp.port);
 }
@@ -262,7 +264,7 @@ static int find_pattern(const char *data, size_t dlen,
 {
 	size_t i;
 
-	pr_debug("find_pattern `%s': dlen = %Zu\n", pattern, dlen);
+	pr_debug("`%s': dlen = %Zu\n", pattern, dlen);
 	if (dlen == 0)
 		return 0;
 
@@ -277,9 +279,9 @@ static int find_pattern(const char *data, size_t dlen,
 #if 0
 		size_t i;
 
-		pr_debug("ftp: string mismatch\n");
+		pr_debug("string mismatch\n");
 		for (i = 0; i < plen; i++) {
-			pr_debug("ftp:char %u `%c'(%u) vs `%c'(%u)\n",
+			pr_debug("char %u `%c'(%u) vs `%c'(%u)\n",
 				 i, data[i], data[i],
 				 pattern[i], pattern[i]);
 		}
@@ -368,7 +370,7 @@ static int help(struct sk_buff *skb,
 	/* Until there's been traffic both ways, don't look in packets. */
 	if (ctinfo != IP_CT_ESTABLISHED
 	    && ctinfo != IP_CT_ESTABLISHED+IP_CT_IS_REPLY) {
-		pr_debug("ftp: Conntrackinfo = %u\n", ctinfo);
+		pr_debug("Conntrackinfo = %u\n", ctinfo);
 		return NF_ACCEPT;
 	}
 
@@ -379,7 +381,7 @@ static int help(struct sk_buff *skb,
 	dataoff = protoff + th->doff * 4;
 	/* No data? */
 	if (dataoff >= skb->len) {
-		pr_debug("ftp: dataoff(%u) >= skblen(%u)\n", dataoff,
+		pr_debug("dataoff(%u) >= skblen(%u)\n", dataoff,
 			 skb->len);
 		return NF_ACCEPT;
 	}
@@ -395,7 +397,7 @@ static int help(struct sk_buff *skb,
 	/* Look up to see if we're just after a \n. */
 	if (!find_nl_seq(ntohl(th->seq), ct_ftp_info, dir)) {
 		/* Now if this ends in \n, update ftp info. */
-		pr_debug("nf_conntrack_ftp: wrong seq pos %s(%u) or %s(%u)\n",
+		pr_debug("wrong seq pos %s(%u) or %s(%u)\n",
 			 ct_ftp_info->seq_aft_nl_num[dir] > 0 ? "" : "(UNSET)",
 			 ct_ftp_info->seq_aft_nl[dir][0],
 			 ct_ftp_info->seq_aft_nl_num[dir] > 1 ? "" : "(UNSET)",
@@ -426,7 +428,7 @@ static int help(struct sk_buff *skb,
 		   connection tracking, not packet filtering.
 		   However, it is necessary for accurate tracking in
 		   this case. */
-		pr_debug("conntrack_ftp: partial %s %u+%u\n",
+		pr_debug("partial %s %u+%u\n",
 			 search[dir][i].pattern,  ntohl(th->seq), datalen);
 		ret = NF_DROP;
 		goto out;
@@ -435,7 +437,7 @@ static int help(struct sk_buff *skb,
 		goto out_update_nl;
 	}
 
-	pr_debug("conntrack_ftp: match `%.*s' (%u bytes at %u)\n",
+	pr_debug("match `%.*s' (%u bytes at %u)\n",
 		 matchlen, fb_ptr + matchoff,
 		 matchlen, ntohl(th->seq) + matchoff);
 
@@ -459,11 +461,11 @@ static int help(struct sk_buff *skb,
 		   different IP address.  Simply don't record it for
 		   NAT. */
 		if (cmd.l3num == PF_INET) {
-			pr_debug("conntrack_ftp: NOT RECORDING: %pI4 != %pI4\n",
+			pr_debug("NOT RECORDING: %pI4 != %pI4\n",
 				 &cmd.u3.ip,
 				 &ct->tuplehash[dir].tuple.src.u3.ip);
 		} else {
-			pr_debug("conntrack_ftp: NOT RECORDING: %pI6 != %pI6\n",
+			pr_debug("NOT RECORDING: %pI6 != %pI6\n",
 				 cmd.u3.ip6,
 				 ct->tuplehash[dir].tuple.src.u3.ip6);
 		}
@@ -527,8 +529,7 @@ static void nf_conntrack_ftp_fini(void)
 			if (ftp[i][j].me == NULL)
 				continue;
 
-			pr_debug("nf_ct_ftp: unregistering helper for pf: %d "
-				 "port: %d\n",
+			pr_debug("unregistering helper for pf: %d port: %d\n",
 				 ftp[i][j].tuple.src.l3num, ports[i]);
 			nf_conntrack_helper_unregister(&ftp[i][j]);
 		}
@@ -567,13 +568,12 @@ static int __init nf_conntrack_ftp_init(void)
 				sprintf(tmpname, "ftp-%d", ports[i]);
 			ftp[i][j].name = tmpname;
 
-			pr_debug("nf_ct_ftp: registering helper for pf: %d "
-				 "port: %d\n",
+			pr_debug("registering helper for pf: %d port: %d\n",
 				 ftp[i][j].tuple.src.l3num, ports[i]);
 			ret = nf_conntrack_helper_register(&ftp[i][j]);
 			if (ret) {
-				printk("nf_ct_ftp: failed to register helper "
-				       " for pf: %d port: %d\n",
+				pr_info("failed to register helper for pf: %d "
+					"port: %d\n",
 					ftp[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_ftp_fini();
 				return ret;
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 6636949..47a9510 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -11,6 +11,8 @@
  * For more information, please see http://nath323.sourceforge.net/
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/ctype.h>
@@ -145,9 +147,8 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 		if (tcpdatalen < 4 || tpkt[0] != 0x03 || tpkt[1] != 0) {
 			/* Netmeeting sends TPKT header and data separately */
 			if (info->tpkt_len[dir] > 0) {
-				pr_debug("nf_ct_h323: previous packet "
-					 "indicated separate TPKT data of %hu "
-					 "bytes\n", info->tpkt_len[dir]);
+				pr_debug("previous packet indicated separate TPKT data of %hu bytes\n",
+					 info->tpkt_len[dir]);
 				if (info->tpkt_len[dir] <= tcpdatalen) {
 					/* Yes, there was a TPKT header
 					 * received */
@@ -158,7 +159,7 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 				}
 
 				/* Fragmented TPKT */
-				pr_debug("nf_ct_h323: fragmented TPKT\n");
+				pr_debug("fragmented TPKT\n");
 				goto clear_out;
 			}
 
@@ -185,15 +186,14 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 	if (tpktlen > tcpdatalen) {
 		if (tcpdatalen == 4) {	/* Separate TPKT header */
 			/* Netmeeting sends TPKT header and data separately */
-			pr_debug("nf_ct_h323: separate TPKT header indicates "
-				 "there will be TPKT data of %hu bytes\n",
+			pr_debug("separate TPKT header indicates there will be TPKT data of %hu bytes\n",
 				 tpktlen - 4);
 			info->tpkt_len[dir] = tpktlen - 4;
 			return 0;
 		}
 
 		if (net_ratelimit())
-			printk("nf_ct_h323: incomplete TPKT (fragmented?)\n");
+			pr_info("incomplete TPKT (fragmented?)\n");
 		goto clear_out;
 	}
 
@@ -302,9 +302,9 @@ static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(rtp_exp) == 0) {
 			if (nf_ct_expect_related(rtcp_exp) == 0) {
-				pr_debug("nf_ct_h323: expect RTP ");
+				pr_debug("expect RTP ");
 				nf_ct_dump_tuple(&rtp_exp->tuple);
-				pr_debug("nf_ct_h323: expect RTCP ");
+				pr_debug("expect RTCP ");
 				nf_ct_dump_tuple(&rtcp_exp->tuple);
 			} else {
 				nf_ct_unexpect_related(rtp_exp);
@@ -359,7 +359,7 @@ static int expect_t120(struct sk_buff *skb,
 			       port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
-			pr_debug("nf_ct_h323: expect T.120 ");
+			pr_debug("expect T.120 ");
 			nf_ct_dump_tuple(&exp->tuple);
 		} else
 			ret = -1;
@@ -407,7 +407,7 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 {
 	int ret;
 
-	pr_debug("nf_ct_h323: OpenLogicalChannel\n");
+	pr_debug("OpenLogicalChannel\n");
 
 	if (olc->forwardLogicalChannelParameters.multiplexParameters.choice ==
 	    eOpenLogicalChannel_forwardLogicalChannelParameters_multiplexParameters_h2250LogicalChannelParameters)
@@ -467,7 +467,7 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 	H2250LogicalChannelAckParameters *ack;
 	int ret;
 
-	pr_debug("nf_ct_h323: OpenLogicalChannelAck\n");
+	pr_debug("OpenLogicalChannelAck\n");
 
 	if ((olca->options &
 	     eOpenLogicalChannelAck_reverseLogicalChannelParameters) &&
@@ -538,8 +538,7 @@ static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 			return process_olc(skb, ct, ctinfo, data, dataoff,
 					   &mscm->request.openLogicalChannel);
 		}
-		pr_debug("nf_ct_h323: H.245 Request %d\n",
-			 mscm->request.choice);
+		pr_debug("H.245 Request %d\n", mscm->request.choice);
 		break;
 	case eMultimediaSystemControlMessage_response:
 		if (mscm->response.choice ==
@@ -548,11 +547,10 @@ static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 					    &mscm->response.
 					    openLogicalChannelAck);
 		}
-		pr_debug("nf_ct_h323: H.245 Response %d\n",
-			 mscm->response.choice);
+		pr_debug("H.245 Response %d\n", mscm->response.choice);
 		break;
 	default:
-		pr_debug("nf_ct_h323: H.245 signal %d\n", mscm->choice);
+		pr_debug("H.245 signal %d\n", mscm->choice);
 		break;
 	}
 
@@ -574,21 +572,21 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 	    ctinfo != IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
 		return NF_ACCEPT;
 	}
-	pr_debug("nf_ct_h245: skblen = %u\n", skb->len);
+	pr_debug("skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
 	/* Process each TPKT */
 	while (get_tpkt_data(skb, protoff, ct, ctinfo,
 			     &data, &datalen, &dataoff)) {
-		pr_debug("nf_ct_h245: TPKT len=%d ", datalen);
+		pr_debug("TPKT len=%d ", datalen);
 		nf_ct_dump_tuple(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
 
 		/* Decode H.245 signal */
 		ret = DecodeMultimediaSystemControlMessage(data, datalen,
 							   &mscm);
 		if (ret < 0) {
-			pr_debug("nf_ct_h245: decoding error: %s\n",
+			pr_debug("decoding error: %s\n",
 				 ret == H323_ERROR_BOUND ?
 				 "out of bound" : "out of range");
 			/* We don't drop when decoding error */
@@ -606,7 +604,7 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_h245: packet dropped\n");
+		pr_info("packet dropped\n");
 	return NF_DROP;
 }
 
@@ -695,7 +693,7 @@ static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 			       port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
-			pr_debug("nf_ct_q931: expect H.245 ");
+			pr_debug("expect H.245 ");
 			nf_ct_dump_tuple(&exp->tuple);
 		} else
 			ret = -1;
@@ -789,7 +787,7 @@ static int expect_callforwarding(struct sk_buff *skb,
 	if (callforward_filter &&
 	    callforward_do_filter(&addr, &ct->tuplehash[!dir].tuple.src.u3,
 				  nf_ct_l3num(ct))) {
-		pr_debug("nf_ct_q931: Call Forwarding not tracked\n");
+		pr_debug("Call Forwarding not tracked\n");
 		return 0;
 	}
 
@@ -811,7 +809,7 @@ static int expect_callforwarding(struct sk_buff *skb,
 					 taddr, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
-			pr_debug("nf_ct_q931: expect Call Forwarding ");
+			pr_debug("expect Call Forwarding ");
 			nf_ct_dump_tuple(&exp->tuple);
 		} else
 			ret = -1;
@@ -835,7 +833,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 	typeof(set_h225_addr_hook) set_h225_addr;
 
-	pr_debug("nf_ct_q931: Setup\n");
+	pr_debug("Setup\n");
 
 	if (setup->options & eSetup_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -850,7 +848,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &setup->destCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.src.u3, sizeof(addr))) {
-		pr_debug("nf_ct_q931: set destCallSignalAddress %pI6:%hu->%pI6:%hu\n",
+		pr_debug("set destCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.src.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.src.u.tcp.port));
 		ret = set_h225_addr(skb, data, dataoff,
@@ -866,7 +864,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &setup->sourceCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.dst.u3, sizeof(addr))) {
-		pr_debug("nf_ct_q931: set sourceCallSignalAddress %pI6:%hu->%pI6:%hu\n",
+		pr_debug("set sourceCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.dst.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.dst.u.tcp.port));
 		ret = set_h225_addr(skb, data, dataoff,
@@ -899,7 +897,7 @@ static int process_callproceeding(struct sk_buff *skb,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: CallProceeding\n");
+	pr_debug("CallProceeding\n");
 
 	if (callproc->options & eCallProceeding_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -929,7 +927,7 @@ static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: Connect\n");
+	pr_debug("Connect\n");
 
 	if (connect->options & eConnect_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -959,7 +957,7 @@ static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: Alerting\n");
+	pr_debug("Alerting\n");
 
 	if (alert->options & eAlerting_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -989,7 +987,7 @@ static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: Facility\n");
+	pr_debug("Facility\n");
 
 	if (facility->reason.choice == eFacilityReason_callForwarded) {
 		if (facility->options & eFacility_UUIE_alternativeAddress)
@@ -1028,7 +1026,7 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: Progress\n");
+	pr_debug("Progress\n");
 
 	if (progress->options & eProgress_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -1085,7 +1083,7 @@ static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 				       &pdu->h323_message_body.progress);
 		break;
 	default:
-		pr_debug("nf_ct_q931: Q.931 signal %d\n",
+		pr_debug("Q.931 signal %d\n",
 			 pdu->h323_message_body.choice);
 		break;
 	}
@@ -1120,20 +1118,20 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 	    ctinfo != IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
 		return NF_ACCEPT;
 	}
-	pr_debug("nf_ct_q931: skblen = %u\n", skb->len);
+	pr_debug("skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
 	/* Process each TPKT */
 	while (get_tpkt_data(skb, protoff, ct, ctinfo,
 			     &data, &datalen, &dataoff)) {
-		pr_debug("nf_ct_q931: TPKT len=%d ", datalen);
+		pr_debug("TPKT len=%d ", datalen);
 		nf_ct_dump_tuple(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
 
 		/* Decode Q.931 signal */
 		ret = DecodeQ931(data, datalen, &q931);
 		if (ret < 0) {
-			pr_debug("nf_ct_q931: decoding error: %s\n",
+			pr_debug("decoding error: %s\n",
 				 ret == H323_ERROR_BOUND ?
 				 "out of bound" : "out of range");
 			/* We don't drop when decoding error */
@@ -1151,7 +1149,7 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_q931: packet dropped\n");
+		pr_info("packet dropped\n");
 	return NF_DROP;
 }
 
@@ -1277,7 +1275,7 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 		ret = nat_q931(skb, ct, ctinfo, data, taddr, i, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
-			pr_debug("nf_ct_ras: expect Q.931 ");
+			pr_debug("expect Q.931 ");
 			nf_ct_dump_tuple(&exp->tuple);
 
 			/* Save port for looking up expect in processing RCF */
@@ -1298,7 +1296,7 @@ static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 {
 	typeof(set_ras_addr_hook) set_ras_addr;
 
-	pr_debug("nf_ct_ras: GRQ\n");
+	pr_debug("GRQ\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK)	/* NATed */
@@ -1318,7 +1316,7 @@ static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 	struct nf_conntrack_expect *exp;
 
-	pr_debug("nf_ct_ras: GCF\n");
+	pr_debug("GCF\n");
 
 	if (!get_h225_addr(ct, *data, &gcf->rasAddress, &addr, &port))
 		return 0;
@@ -1341,7 +1339,7 @@ static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 	exp->helper = nf_conntrack_helper_ras;
 
 	if (nf_ct_expect_related(exp) == 0) {
-		pr_debug("nf_ct_ras: expect RAS ");
+		pr_debug("expect RAS ");
 		nf_ct_dump_tuple(&exp->tuple);
 	} else
 		ret = -1;
@@ -1360,7 +1358,7 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	typeof(set_ras_addr_hook) set_ras_addr;
 
-	pr_debug("nf_ct_ras: RRQ\n");
+	pr_debug("RRQ\n");
 
 	ret = expect_q931(skb, ct, ctinfo, data,
 			  rrq->callSignalAddress.item,
@@ -1378,7 +1376,7 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (rrq->options & eRegistrationRequest_timeToLive) {
-		pr_debug("nf_ct_ras: RRQ TTL = %u seconds\n", rrq->timeToLive);
+		pr_debug("RRQ TTL = %u seconds\n", rrq->timeToLive);
 		info->timeout = rrq->timeToLive;
 	} else
 		info->timeout = default_rrq_ttl;
@@ -1397,7 +1395,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 	struct nf_conntrack_expect *exp;
 	typeof(set_sig_addr_hook) set_sig_addr;
 
-	pr_debug("nf_ct_ras: RCF\n");
+	pr_debug("RCF\n");
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
@@ -1409,12 +1407,12 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (rcf->options & eRegistrationConfirm_timeToLive) {
-		pr_debug("nf_ct_ras: RCF TTL = %u seconds\n", rcf->timeToLive);
+		pr_debug("RCF TTL = %u seconds\n", rcf->timeToLive);
 		info->timeout = rcf->timeToLive;
 	}
 
 	if (info->timeout > 0) {
-		pr_debug("nf_ct_ras: set RAS connection timeout to "
+		pr_debug("set RAS connection timeout to "
 			 "%u seconds\n", info->timeout);
 		nf_ct_refresh(ct, skb, info->timeout * HZ);
 
@@ -1423,8 +1421,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 		exp = find_expect(ct, &ct->tuplehash[dir].tuple.dst.u3,
 				  info->sig_port[!dir]);
 		if (exp) {
-			pr_debug("nf_ct_ras: set Q.931 expect "
-				 "timeout to %u seconds for",
+			pr_debug("set Q.931 expect timeout to %u seconds for",
 				 info->timeout);
 			nf_ct_dump_tuple(&exp->tuple);
 			set_expect_timeout(exp, info->timeout);
@@ -1445,7 +1442,7 @@ static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	typeof(set_sig_addr_hook) set_sig_addr;
 
-	pr_debug("nf_ct_ras: URQ\n");
+	pr_debug("URQ\n");
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
@@ -1478,7 +1475,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 	typeof(set_h225_addr_hook) set_h225_addr;
 
-	pr_debug("nf_ct_ras: ARQ\n");
+	pr_debug("ARQ\n");
 
 	set_h225_addr = rcu_dereference(set_h225_addr_hook);
 	if ((arq->options & eAdmissionRequest_destCallSignalAddress) &&
@@ -1521,7 +1518,7 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 	struct nf_conntrack_expect *exp;
 	typeof(set_sig_addr_hook) set_sig_addr;
 
-	pr_debug("nf_ct_ras: ACF\n");
+	pr_debug("ACF\n");
 
 	if (!get_h225_addr(ct, *data, &acf->destCallSignalAddress,
 			   &addr, &port))
@@ -1546,7 +1543,7 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 	exp->helper = nf_conntrack_helper_q931;
 
 	if (nf_ct_expect_related(exp) == 0) {
-		pr_debug("nf_ct_ras: expect Q.931 ");
+		pr_debug("expect Q.931 ");
 		nf_ct_dump_tuple(&exp->tuple);
 	} else
 		ret = -1;
@@ -1563,7 +1560,7 @@ static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 {
 	typeof(set_ras_addr_hook) set_ras_addr;
 
-	pr_debug("nf_ct_ras: LRQ\n");
+	pr_debug("LRQ\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK)
@@ -1583,7 +1580,7 @@ static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 	struct nf_conntrack_expect *exp;
 
-	pr_debug("nf_ct_ras: LCF\n");
+	pr_debug("LCF\n");
 
 	if (!get_h225_addr(ct, *data, &lcf->callSignalAddress,
 			   &addr, &port))
@@ -1599,7 +1596,7 @@ static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 	exp->helper = nf_conntrack_helper_q931;
 
 	if (nf_ct_expect_related(exp) == 0) {
-		pr_debug("nf_ct_ras: expect Q.931 ");
+		pr_debug("expect Q.931 ");
 		nf_ct_dump_tuple(&exp->tuple);
 	} else
 		ret = -1;
@@ -1620,7 +1617,7 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 	typeof(set_ras_addr_hook) set_ras_addr;
 	typeof(set_sig_addr_hook) set_sig_addr;
 
-	pr_debug("nf_ct_ras: IRR\n");
+	pr_debug("IRR\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK) {
@@ -1679,7 +1676,7 @@ static int process_ras(struct sk_buff *skb, struct nf_conn *ct,
 		return process_irr(skb, ct, ctinfo, data,
 				   &ras->infoRequestResponse);
 	default:
-		pr_debug("nf_ct_ras: RAS message %d\n", ras->choice);
+		pr_debug("RAS message %d\n", ras->choice);
 		break;
 	}
 
@@ -1695,7 +1692,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 	int datalen = 0;
 	int ret;
 
-	pr_debug("nf_ct_ras: skblen = %u\n", skb->len);
+	pr_debug("skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
@@ -1703,13 +1700,13 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 	data = get_udp_data(skb, protoff, &datalen);
 	if (data == NULL)
 		goto accept;
-	pr_debug("nf_ct_ras: RAS message len=%d ", datalen);
+	pr_debug("RAS message len=%d ", datalen);
 	nf_ct_dump_tuple(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
 
 	/* Decode RAS message */
 	ret = DecodeRasMessage(data, datalen, &ras);
 	if (ret < 0) {
-		pr_debug("nf_ct_ras: decoding error: %s\n",
+		pr_debug("decoding error: %s\n",
 			 ret == H323_ERROR_BOUND ?
 			 "out of bound" : "out of range");
 		goto accept;
@@ -1726,7 +1723,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_ras: packet dropped\n");
+		pr_info("packet dropped\n");
 	return NF_DROP;
 }
 
@@ -1766,7 +1763,7 @@ static void __exit nf_conntrack_h323_fini(void)
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[0]);
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
 	kfree(h323_buffer);
-	pr_debug("nf_ct_h323: fini\n");
+	pr_debug("fini\n");
 }
 
 /****************************************************************************/
@@ -1792,7 +1789,7 @@ static int __init nf_conntrack_h323_init(void)
 	ret = nf_conntrack_helper_register(&nf_conntrack_helper_ras[1]);
 	if (ret < 0)
 		goto err5;
-	pr_debug("nf_ct_h323: init success\n");
+	pr_debug("init success\n");
 	return 0;
 
 err5:
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 0fa5a42..f4f0b51 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -9,6 +9,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/types.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 8bd98c8..2d1a510 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -8,6 +8,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/skbuff.h>
@@ -186,10 +188,9 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 			if (tuple->src.u3.ip != dcc_ip &&
 			    tuple->dst.u3.ip != dcc_ip) {
 				if (net_ratelimit())
-					printk(KERN_WARNING
-						"Forged DCC command from %pI4: %pI4:%u\n",
-						&tuple->src.u3.ip,
-						&dcc_ip, dcc_port);
+					pr_warning("Forged DCC command from %pI4: %pI4:%u\n",
+						   &tuple->src.u3.ip,
+						   &dcc_ip, dcc_port);
 				continue;
 			}
 
@@ -234,7 +235,7 @@ static int __init nf_conntrack_irc_init(void)
 	char *tmpname;
 
 	if (max_dcc_channels < 1) {
-		printk("nf_ct_irc: max_dcc_channels must not be zero\n");
+		pr_info("max_dcc_channels must not be zero\n");
 		return -EINVAL;
 	}
 
@@ -266,9 +267,8 @@ static int __init nf_conntrack_irc_init(void)
 
 		ret = nf_conntrack_helper_register(&irc[i]);
 		if (ret) {
-			printk("nf_ct_irc: failed to register helper "
-			       "for pf: %u port: %u\n",
-			       irc[i].tuple.src.l3num, ports[i]);
+			pr_info("failed to register helper for pf: %u port: %u\n",
+				irc[i].tuple.src.l3num, ports[i]);
 			nf_conntrack_irc_fini();
 			return ret;
 		}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4e503ad..70bfb9a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -15,6 +15,8 @@
  * of the GNU General Public License, incorporated herein by reference.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -1920,29 +1922,29 @@ static int __init ctnetlink_init(void)
 {
 	int ret;
 
-	printk("ctnetlink v%s: registering with nfnetlink.\n", version);
+	pr_info("v%s: registering with nfnetlink.\n", version);
 	ret = nfnetlink_subsys_register(&ctnl_subsys);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register with nfnetlink.\n");
+		pr_info("cannot register with nfnetlink.\n");
 		goto err_out;
 	}
 
 	ret = nfnetlink_subsys_register(&ctnl_exp_subsys);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register exp with nfnetlink.\n");
+		pr_info("cannot register exp with nfnetlink.\n");
 		goto err_unreg_subsys;
 	}
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	ret = nf_conntrack_register_notifier(&ctnl_notifier);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register notifier.\n");
+		pr_info("cannot register notifier.\n");
 		goto err_unreg_exp_subsys;
 	}
 
 	ret = nf_ct_expect_register_notifier(&ctnl_notifier_exp);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot expect register notifier.\n");
+		pr_info("cannot expect register notifier.\n");
 		goto err_unreg_notifier;
 	}
 #endif
@@ -1963,7 +1965,7 @@ err_out:
 
 static void __exit ctnetlink_exit(void)
 {
-	printk("ctnetlink: unregistering from nfnetlink.\n");
+	pr_info("unregistering from nfnetlink.\n");
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	nf_ct_expect_unregister_notifier(&ctnl_notifier_exp);
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 3807ac7..8258403 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -20,6 +20,8 @@
  *	 - testing of incoming PPTP calls
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/in.h>
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index a54a0af..66f02f0 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -23,6 +23,8 @@
  *
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/timer.h>
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index c10e6f3..2bf6fc8 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -9,6 +9,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/netfilter.h>
@@ -721,12 +723,12 @@ static int __init nf_conntrack_proto_sctp_init(void)
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp4);
 	if (ret) {
-		printk("nf_conntrack_l4proto_sctp4: protocol register failed\n");
+		pr_info("nf_conntrack_l4proto_sctp4: protocol register failed\n");
 		goto out;
 	}
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp6);
 	if (ret) {
-		printk("nf_conntrack_l4proto_sctp6: protocol register failed\n");
+		pr_info("nf_conntrack_l4proto_sctp6: protocol register failed\n");
 		goto cleanup_sctp4;
 	}
 
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 5142e60..4ca4d6c 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -6,6 +6,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/module.h>
@@ -519,12 +521,12 @@ static bool tcp_in_window(const struct nf_conn *ct,
 	if (receiver->flags & IP_CT_TCP_FLAG_SACK_PERM)
 		tcp_sack(skb, dataoff, tcph, &sack);
 
-	pr_debug("tcp_in_window: START\n");
-	pr_debug("tcp_in_window: ");
+	pr_debug("START\n");
+	pr_debug("");
 	nf_ct_dump_tuple(tuple);
 	pr_debug("seq=%u ack=%u sack=%u win=%u end=%u\n",
 		 seq, ack, sack, win, end);
-	pr_debug("tcp_in_window: sender end=%u maxend=%u maxwin=%u scale=%i "
+	pr_debug("sender end=%u maxend=%u maxwin=%u scale=%i "
 		 "receiver end=%u maxend=%u maxwin=%u scale=%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
 		 sender->td_scale,
@@ -611,18 +613,18 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		 */
 		seq = end = sender->td_end;
 
-	pr_debug("tcp_in_window: ");
+	pr_debug("");
 	nf_ct_dump_tuple(tuple);
 	pr_debug("seq=%u ack=%u sack =%u win=%u end=%u\n",
 		 seq, ack, sack, win, end);
-	pr_debug("tcp_in_window: sender end=%u maxend=%u maxwin=%u scale=%i "
+	pr_debug("sender end=%u maxend=%u maxwin=%u scale=%i "
 		 "receiver end=%u maxend=%u maxwin=%u scale=%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
 		 sender->td_scale,
 		 receiver->td_end, receiver->td_maxend, receiver->td_maxwin,
 		 receiver->td_scale);
 
-	pr_debug("tcp_in_window: I=%i II=%i III=%i IV=%i\n",
+	pr_debug("I=%i II=%i III=%i IV=%i\n",
 		 before(seq, sender->td_maxend + 1),
 		 after(end, sender->td_end - receiver->td_maxwin - 1),
 		 before(sack, receiver->td_end + 1),
@@ -707,7 +709,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 			: "SEQ is over the upper bound (over the window of the receiver)");
 	}
 
-	pr_debug("tcp_in_window: res=%u sender end=%u maxend=%u maxwin=%u "
+	pr_debug("res=%u sender end=%u maxend=%u maxwin=%u "
 		 "receiver end=%u maxend=%u maxwin=%u\n",
 		 res, sender->td_end, sender->td_maxend, sender->td_maxwin,
 		 receiver->td_end, receiver->td_maxend, receiver->td_maxwin);
@@ -738,7 +740,7 @@ void nf_conntrack_tcp_update(const struct sk_buff *skb,
 		ct->proto.tcp.seen[dir].td_end = end;
 	ct->proto.tcp.last_end = end;
 	spin_unlock_bh(&ct->lock);
-	pr_debug("tcp_update: sender end=%u maxend=%u maxwin=%u scale=%i "
+	pr_debug("sender end=%u maxend=%u maxwin=%u scale=%i "
 		 "receiver end=%u maxend=%u maxwin=%u scale=%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
 		 sender->td_scale,
@@ -932,7 +934,7 @@ static int tcp_packet(struct nf_conn *ct,
 		return NF_ACCEPT;
 	case TCP_CONNTRACK_MAX:
 		/* Invalid packet */
-		pr_debug("nf_ct_tcp: Invalid dir=%i index=%u ostate=%u\n",
+		pr_debug("Invalid dir=%i index=%u ostate=%u\n",
 			 dir, get_conntrack_index(th), old_state);
 		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
@@ -944,7 +946,9 @@ static int tcp_packet(struct nf_conn *ct,
 		    && (ct->proto.tcp.seen[!dir].flags & IP_CT_TCP_FLAG_MAXACK_SET)
 		    && before(ntohl(th->seq), ct->proto.tcp.seen[!dir].td_maxack)) {
 			/* Invalid RST  */
+#if 0
 			write_unlock_bh(&tcp_lock);
+#endif
 			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: invalid RST ");
@@ -983,7 +987,7 @@ static int tcp_packet(struct nf_conn *ct,
 	ct->proto.tcp.last_index = index;
 	ct->proto.tcp.last_dir = dir;
 
-	pr_debug("tcp_conntracks: ");
+	pr_debug("");
 	nf_ct_dump_tuple(tuple);
 	pr_debug("syn=%i ack=%i fin=%i rst=%i old=%i new=%i\n",
 		 (th->syn ? 1 : 0), (th->ack ? 1 : 0),
@@ -1053,7 +1057,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 	/* Invalid: delete conntrack */
 	if (new_state >= TCP_CONNTRACK_MAX) {
-		pr_debug("nf_ct_tcp: invalid new deleting.\n");
+		pr_debug("invalid new deleting.\n");
 		return false;
 	}
 
@@ -1106,7 +1110,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	ct->proto.tcp.state = TCP_CONNTRACK_NONE;
 	ct->proto.tcp.last_index = TCP_NONE_SET;
 
-	pr_debug("tcp_new: sender end=%u maxend=%u maxwin=%u scale=%i "
+	pr_debug("sender end=%u maxend=%u maxwin=%u scale=%i "
 		 "receiver end=%u maxend=%u maxwin=%u scale=%i\n",
 		 sender->td_end, sender->td_maxend, sender->td_maxwin,
 		 sender->td_scale,
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index dcfecbb..bfb2e04 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -17,6 +17,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/netfilter.h>
@@ -120,14 +122,14 @@ static int help(struct sk_buff *skb,
 	ct_sane_info->state = SANE_STATE_NORMAL;
 
 	if (datalen < sizeof(struct sane_reply_net_start)) {
-		pr_debug("nf_ct_sane: NET_START reply too short\n");
+		pr_debug("NET_START reply too short\n");
 		goto out;
 	}
 
 	reply = sb_ptr;
 	if (reply->status != htonl(SANE_STATUS_SUCCESS)) {
 		/* saned refused the command */
-		pr_debug("nf_ct_sane: unsuccessful SANE_STATUS = %u\n",
+		pr_debug("unsuccessful SANE_STATUS = %u\n",
 			 ntohl(reply->status));
 		goto out;
 	}
@@ -147,7 +149,7 @@ static int help(struct sk_buff *skb,
 			  &tuple->src.u3, &tuple->dst.u3,
 			  IPPROTO_TCP, NULL, &reply->port);
 
-	pr_debug("nf_ct_sane: expect: ");
+	pr_debug("expect: ");
 	nf_ct_dump_tuple(&exp->tuple);
 
 	/* Can't expect this?  Best to drop packet now. */
@@ -176,8 +178,7 @@ static void nf_conntrack_sane_fini(void)
 
 	for (i = 0; i < ports_c; i++) {
 		for (j = 0; j < 2; j++) {
-			pr_debug("nf_ct_sane: unregistering helper for pf: %d "
-				 "port: %d\n",
+			pr_debug("unregistering helper for pf: %d port: %d\n",
 				 sane[i][j].tuple.src.l3num, ports[i]);
 			nf_conntrack_helper_unregister(&sane[i][j]);
 		}
@@ -216,14 +217,13 @@ static int __init nf_conntrack_sane_init(void)
 				sprintf(tmpname, "sane-%d", ports[i]);
 			sane[i][j].name = tmpname;
 
-			pr_debug("nf_ct_sane: registering helper for pf: %d "
-				 "port: %d\n",
+			pr_debug("registering helper for pf: %d port: %d\n",
 				 sane[i][j].tuple.src.l3num, ports[i]);
 			ret = nf_conntrack_helper_register(&sane[i][j]);
 			if (ret) {
-				printk(KERN_ERR "nf_ct_sane: failed to "
-				       "register helper for pf: %d port: %d\n",
-					sane[i][j].tuple.src.l3num, ports[i]);
+				pr_err("failed to register helper for pf: %d "
+				       "port: %d\n",
+				       sane[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_sane_fini();
 				return ret;
 			}
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4b57216..9fc893f 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -10,6 +10,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/ctype.h>
 #include <linux/skbuff.h>
@@ -172,7 +174,7 @@ static int epaddr_len(const struct nf_conn *ct, const char *dptr,
 	const char *aux = dptr;
 
 	if (!parse_addr(ct, dptr, &dptr, &addr, limit)) {
-		pr_debug("ip: %s parse failed.!\n", dptr);
+		pr_debug("%s parse failed.!\n", dptr);
 		return 0;
 	}
 
@@ -1363,9 +1365,9 @@ static int __init nf_conntrack_sip_init(void)
 
 			ret = nf_conntrack_helper_register(&sip[i][j]);
 			if (ret) {
-				printk("nf_ct_sip: failed to register helper "
-				       "for pf: %u port: %u\n",
-				       sip[i][j].tuple.src.l3num, ports[i]);
+				pr_info("failed to register helper for pf: %u "
+					"port: %u\n",
+					sip[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_sip_fini();
 				return ret;
 			}
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 1935153..2d762b8 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -6,6 +6,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/types.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
@@ -445,7 +447,7 @@ out_kmemdup:
 	if (net_eq(net, &init_net))
 		unregister_sysctl_table(nf_ct_netfilter_header);
 out:
-	printk("nf_conntrack: can't register to sysctl.\n");
+	pr_info("can't register to sysctl.\n");
 	return -ENOMEM;
 }
 
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 46e646b..dca482f 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -5,6 +5,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/in.h>
@@ -138,8 +140,8 @@ static int __init nf_conntrack_tftp_init(void)
 
 			ret = nf_conntrack_helper_register(&tftp[i][j]);
 			if (ret) {
-				printk("nf_ct_tftp: failed to register helper "
-				       "for pf: %u port: %u\n",
+				pr_info("failed to register helper for pf: %u "
+					"port: %u\n",
 					tftp[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_tftp_fini();
 				return ret;
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index 5490fc3..98486a8 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -10,6 +10,8 @@
  *
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 
 #include <linux/net.h>
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 92761a9..4371049 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -14,6 +14,8 @@
  * of the GNU General Public License, incorporated herein by reference.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -186,19 +188,19 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 
 static void __exit nfnetlink_exit(void)
 {
-	printk("Removing netfilter NETLINK layer.\n");
+	pr_info("Removing netfilter NETLINK layer.\n");
 	netlink_kernel_release(nfnl);
 	return;
 }
 
 static int __init nfnetlink_init(void)
 {
-	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
+	pr_info("Netfilter messages via NETLINK v%s.\n", nfversion);
 
 	nfnl = netlink_kernel_create(&init_net, NETLINK_NETFILTER, NFNLGRP_MAX,
 				     nfnetlink_rcv, NULL, THIS_MODULE);
 	if (!nfnl) {
-		printk(KERN_ERR "cannot initialize nfnetlink!\n");
+		pr_err("cannot initialize nfnetlink!\n");
 		return -ENOMEM;
 	}
 
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 66a6dd5..cf677bf 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -11,6 +11,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
@@ -500,7 +503,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 		int size = nla_attr_size(data_len);
 
 		if (skb_tailroom(inst->skb) < nla_total_size(data_len)) {
-			printk(KERN_WARNING "nfnetlink_log: no tailroom!\n");
+			pr_warning("no tailroom!\n");
 			goto nlmsg_failure;
 		}
 
@@ -954,13 +957,13 @@ static int __init nfnetlink_log_init(void)
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
 	if (status < 0) {
-		printk(KERN_ERR "log: failed to create netlink socket\n");
+		pr_err("failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
 	}
 
 	status = nf_log_register(NFPROTO_UNSPEC, &nfulnl_logger);
 	if (status < 0) {
-		printk(KERN_ERR "log: failed to register logger\n");
+		pr_err("failed to register logger\n");
 		goto cleanup_subsys;
 	}
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 8c86011..d57233d 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -14,6 +14,9 @@
  * published by the Free Software Foundation.
  *
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/init.h>
@@ -362,7 +365,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		int sz = nla_attr_size(data_len);
 
 		if (skb_tailroom(skb) < nla_total_size(data_len)) {
-			printk(KERN_WARNING "nf_queue: no tailroom!\n");
+			pr_warning("no tailroom!\n");
 			goto nlmsg_failure;
 		}
 
@@ -382,7 +385,7 @@ nla_put_failure:
 	if (skb)
 		kfree_skb(skb);
 	if (net_ratelimit())
-		printk(KERN_ERR "nf_queue: error creating packet message\n");
+		pr_err("error creating packet message\n");
 	return NULL;
 }
 
@@ -413,9 +416,9 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	if (queue->queue_total >= queue->queue_maxlen) {
 		queue->queue_dropped++;
 		if (net_ratelimit())
-			  printk(KERN_WARNING "nf_queue: full at %d entries, "
-				 "dropping packets(s). Dropped: %d\n",
-				 queue->queue_total, queue->queue_dropped);
+			pr_warning("full at %d entries, dropping packets(s). "
+				   "Dropped: %d\n",
+				   queue->queue_total, queue->queue_dropped);
 		goto err_out_free_nskb;
 	}
 
@@ -456,8 +459,7 @@ nfqnl_mangle(void *data, int data_len, struct nf_queue_entry *e)
 			nskb = skb_copy_expand(e->skb, skb_headroom(e->skb),
 					       diff, GFP_ATOMIC);
 			if (!nskb) {
-				printk(KERN_WARNING "nf_queue: OOM "
-				      "in mangle, dropping packet\n");
+				pr_warning("OOM in mangle, dropping packet\n");
 				return -ENOMEM;
 			}
 			kfree_skb(e->skb);
@@ -901,7 +903,7 @@ static int __init nfnetlink_queue_init(void)
 	netlink_register_notifier(&nfqnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfqnl_subsys);
 	if (status < 0) {
-		printk(KERN_ERR "nf_queue: failed to create netlink socket\n");
+		pr_err("failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
 	}
 
diff --git a/net/netfilter/xt_CONNMARK.c b/net/netfilter/xt_CONNMARK.c
index d6e5ab4..94bc614 100644
--- a/net/netfilter/xt_CONNMARK.c
+++ b/net/netfilter/xt_CONNMARK.c
@@ -20,6 +20,9 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -118,19 +121,18 @@ static bool connmark_tg_check_v0(const struct xt_tgchk_param *par)
 
 	if (matchinfo->mode == XT_CONNMARK_RESTORE) {
 		if (strcmp(par->table, "mangle") != 0) {
-			printk(KERN_WARNING "CONNMARK: restore can only be "
-			       "called from \"mangle\" table, not \"%s\"\n",
-			       par->table);
+			pr_warning("restore can only be called from \"mangle\" table, not \"%s\"\n",
+				   par->table);
 			return false;
 		}
 	}
 	if (matchinfo->mark > 0xffffffff || matchinfo->mask > 0xffffffff) {
-		printk(KERN_WARNING "CONNMARK: Only supports 32bit mark\n");
+		pr_warning("Only supports 32bit mark\n");
 		return false;
 	}
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_warning("can't load conntrack support for proto=%u\n",
+			   par->family);
 		return false;
 	}
 	return true;
@@ -139,8 +141,8 @@ static bool connmark_tg_check_v0(const struct xt_tgchk_param *par)
 static bool connmark_tg_check(const struct xt_tgchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
-		       "proto=%u\n", par->family);
+		pr_warning("cannot load conntrack support for proto=%u\n",
+			   par->family);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index b54c375..f9ee04d 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -15,6 +15,9 @@
  * published by the Free Software Foundation.
  *
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
@@ -91,8 +94,8 @@ static bool connsecmark_tg_check(const struct xt_tgchk_param *par)
 
 	if (strcmp(par->table, "mangle") != 0 &&
 	    strcmp(par->table, "security") != 0) {
-		printk(KERN_INFO PFX "target only valid in the \'mangle\' "
-		       "or \'security\' tables, not \'%s\'.\n", par->table);
+		pr_info(PFX "target only valid in the \'mangle\' "
+			"or \'security\' tables, not \'%s\'.\n", par->table);
 		return false;
 	}
 
@@ -102,13 +105,13 @@ static bool connsecmark_tg_check(const struct xt_tgchk_param *par)
 		break;
 
 	default:
-		printk(KERN_INFO PFX "invalid mode: %hu\n", info->mode);
+		pr_info(PFX "invalid mode: %hu\n", info->mode);
 		return false;
 	}
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_warning("can't load conntrack support for proto=%u\n",
+			   par->family);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index 6a347e7..7daa372 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -10,6 +10,8 @@
  * See RFC2474 for a description of the DSCP field within the IP Header.
 */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -66,7 +68,7 @@ static bool dscp_tg_check(const struct xt_tgchk_param *par)
 	const struct xt_DSCP_info *info = par->targinfo;
 
 	if (info->dscp > XT_DSCP_MAX) {
-		printk(KERN_WARNING "DSCP: dscp %x out of range\n", info->dscp);
+		pr_warning("dscp %x out of range\n", info->dscp);
 		return false;
 	}
 	return true;
@@ -100,7 +102,7 @@ static bool tos_tg_check_v0(const struct xt_tgchk_param *par)
 	if (tos != IPTOS_LOWDELAY && tos != IPTOS_THROUGHPUT &&
 	    tos != IPTOS_RELIABILITY && tos != IPTOS_MINCOST &&
 	    tos != IPTOS_NORMALSVC) {
-		printk(KERN_WARNING "TOS: bad tos value %#x\n", tos);
+		pr_warning("bad tos value %#x\n", tos);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 10e789e..5b789bd 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -10,6 +10,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -106,8 +108,7 @@ static bool ttl_tg_check(const struct xt_tgchk_param *par)
 	const struct ipt_TTL_info *info = par->targinfo;
 
 	if (info->mode > IPT_TTL_MAXMODE) {
-		printk(KERN_WARNING "ipt_TTL: invalid or unknown Mode %u\n",
-			info->mode);
+		pr_warning("invalid or unknown Mode %u\n", info->mode);
 		return false;
 	}
 	if (info->mode != IPT_TTL_SET && info->ttl == 0)
@@ -120,13 +121,11 @@ static bool hl_tg6_check(const struct xt_tgchk_param *par)
 	const struct ip6t_HL_info *info = par->targinfo;
 
 	if (info->mode > IP6T_HL_MAXMODE) {
-		printk(KERN_WARNING "ip6t_HL: invalid or unknown Mode %u\n",
-			info->mode);
+		pr_warning("invalid or unknown Mode %u\n", info->mode);
 		return false;
 	}
 	if (info->mode != IP6T_HL_SET && info->hop_limit == 0) {
-		printk(KERN_WARNING "ip6t_HL: increment/decrement doesn't "
-			"make sense with value 0\n");
+		pr_warning("increment/decrement doesn't make sense with value 0\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index 8ff7843..3865809 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -19,6 +19,8 @@
  *
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
@@ -87,13 +89,13 @@ static bool led_tg_check(const struct xt_tgchk_param *par)
 	int err;
 
 	if (ledinfo->id[0] == '\0') {
-		printk(KERN_ERR KBUILD_MODNAME ": No 'id' parameter given.\n");
+		pr_err("No 'id' parameter given.\n");
 		return false;
 	}
 
 	ledinternal = kzalloc(sizeof(struct xt_led_info_internal), GFP_KERNEL);
 	if (!ledinternal) {
-		printk(KERN_CRIT KBUILD_MODNAME ": out of memory\n");
+		pr_crit("out of memory\n");
 		return false;
 	}
 
@@ -101,11 +103,9 @@ static bool led_tg_check(const struct xt_tgchk_param *par)
 
 	err = led_trigger_register(&ledinternal->netfilter_led_trigger);
 	if (err) {
-		printk(KERN_CRIT KBUILD_MODNAME
-			": led_trigger_register() failed\n");
+		pr_crit("led_trigger_register() failed\n");
 		if (err == -EEXIST)
-			printk(KERN_ERR KBUILD_MODNAME
-				": Trigger name is already in use.\n");
+			pr_err("Trigger name is already in use.\n");
 		goto exit_alloc;
 	}
 
diff --git a/net/netfilter/xt_MARK.c b/net/netfilter/xt_MARK.c
index 67574bc..f863ea6 100644
--- a/net/netfilter/xt_MARK.c
+++ b/net/netfilter/xt_MARK.c
@@ -10,6 +10,8 @@
  *	published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -71,7 +73,7 @@ static bool mark_tg_check_v0(const struct xt_tgchk_param *par)
 	const struct xt_mark_target_info *markinfo = par->targinfo;
 
 	if (markinfo->mark > 0xffffffff) {
-		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
+		pr_warning("Only supports 32bit wide mark\n");
 		return false;
 	}
 	return true;
@@ -84,12 +86,11 @@ static bool mark_tg_check_v1(const struct xt_tgchk_param *par)
 	if (markinfo->mode != XT_MARK_SET
 	    && markinfo->mode != XT_MARK_AND
 	    && markinfo->mode != XT_MARK_OR) {
-		printk(KERN_WARNING "MARK: unknown mode %u\n",
-		       markinfo->mode);
+		pr_warning("unknown mode %u\n", markinfo->mode);
 		return false;
 	}
 	if (markinfo->mark > 0xffffffff) {
-		printk(KERN_WARNING "MARK: Only supports 32bit wide mark\n");
+		pr_warning("Only supports 32bit wide mark\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index 7a6f9e6..b697157 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -12,6 +12,9 @@
  * published by the Free Software Foundation.
  *
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/selinux.h>
@@ -59,20 +62,20 @@ static bool checkentry_selinux(struct xt_secmark_target_info *info)
 	err = selinux_string_to_sid(sel->selctx, &sel->selsid);
 	if (err) {
 		if (err == -EINVAL)
-			printk(KERN_INFO PFX "invalid SELinux context \'%s\'\n",
-			       sel->selctx);
+			pr_info(PFX "invalid SELinux context \'%s\'\n",
+				sel->selctx);
 		return false;
 	}
 
 	if (!sel->selsid) {
-		printk(KERN_INFO PFX "unable to map SELinux context \'%s\'\n",
-		       sel->selctx);
+		pr_info(PFX "unable to map SELinux context \'%s\'\n",
+			sel->selctx);
 		return false;
 	}
 
 	err = selinux_secmark_relabel_packet_permission(sel->selsid);
 	if (err) {
-		printk(KERN_INFO PFX "unable to obtain relabeling permission\n");
+		pr_info(PFX "unable to obtain relabeling permission\n");
 		return false;
 	}
 
@@ -86,14 +89,14 @@ static bool secmark_tg_check(const struct xt_tgchk_param *par)
 
 	if (strcmp(par->table, "mangle") != 0 &&
 	    strcmp(par->table, "security") != 0) {
-		printk(KERN_INFO PFX "target only valid in the \'mangle\' "
-		       "or \'security\' tables, not \'%s\'.\n", par->table);
+		pr_info(PFX "target only valid in the \'mangle\' "
+			"or \'security\' tables, not \'%s\'.\n", par->table);
 		return false;
 	}
 
 	if (mode && mode != info->mode) {
-		printk(KERN_INFO PFX "mode already set to %hu cannot mix with "
-		       "rules for mode %hu\n", mode, info->mode);
+		pr_info(PFX "mode already set to %hu cannot mix with "
+			"rules for mode %hu\n", mode, info->mode);
 		return false;
 	}
 
@@ -104,7 +107,7 @@ static bool secmark_tg_check(const struct xt_tgchk_param *par)
 		break;
 
 	default:
-		printk(KERN_INFO PFX "invalid mode: %hu\n", info->mode);
+		pr_info(PFX "invalid mode: %hu\n", info->mode);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index eda64c1..209a0ba 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -8,6 +8,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -67,23 +69,21 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	   badly. --RR */
 	if (tcplen != tcph->doff*4) {
 		if (net_ratelimit())
-			printk(KERN_ERR "xt_TCPMSS: bad length (%u bytes)\n",
-			       skb->len);
+			pr_err("bad length (%u bytes)\n", skb->len);
 		return -1;
 	}
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
 			if (net_ratelimit())
-				printk(KERN_ERR "xt_TCPMSS: "
-				       "unknown or invalid path-MTU (%u)\n",
+				pr_err("unknown or invalid path-MTU (%u)\n",
 				       dst_mtu(skb_dst(skb)));
 			return -1;
 		}
 		if (in_mtu <= minlen) {
 			if (net_ratelimit())
-				printk(KERN_ERR "xt_TCPMSS: unknown or "
-				       "invalid path-MTU (%u)\n", in_mtu);
+				pr_err("unknown or invalid path-MTU (%u)\n",
+				       in_mtu);
 			return -1;
 		}
 		newmss = min(dst_mtu(skb_dst(skb)), in_mtu) - minlen;
@@ -246,13 +246,13 @@ static bool tcpmss_tg4_check(const struct xt_tgchk_param *par)
 	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
 			   (1 << NF_INET_LOCAL_OUT) |
 			   (1 << NF_INET_POST_ROUTING))) != 0) {
-		printk("xt_TCPMSS: path-MTU clamping only supported in "
-		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
+		pr_info("path-MTU clamping only supported in "
+			"FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
 	}
 	if (IPT_MATCH_ITERATE(e, find_syn_match))
 		return true;
-	printk("xt_TCPMSS: Only works on TCP SYN packets\n");
+	pr_info("Only works on TCP SYN packets\n");
 	return false;
 }
 
@@ -266,13 +266,13 @@ static bool tcpmss_tg6_check(const struct xt_tgchk_param *par)
 	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
 			   (1 << NF_INET_LOCAL_OUT) |
 			   (1 << NF_INET_POST_ROUTING))) != 0) {
-		printk("xt_TCPMSS: path-MTU clamping only supported in "
+		pr_info("path-MTU clamping only supported in "
 		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
 	}
 	if (IP6T_MATCH_ITERATE(e, find_syn_match))
 		return true;
-	printk("xt_TCPMSS: Only works on TCP SYN packets\n");
+	pr_info("Only works on TCP SYN packets\n");
 	return false;
 }
 #endif
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 69a639f..51f6fec 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -5,6 +5,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/jhash.h>
@@ -136,14 +139,12 @@ static bool xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
 	struct xt_cluster_match_info *info = par->matchinfo;
 
 	if (info->total_nodes > XT_CLUSTER_NODES_MAX) {
-		printk(KERN_ERR "xt_cluster: you have exceeded the maximum "
-				"number of cluster nodes (%u > %u)\n",
-				info->total_nodes, XT_CLUSTER_NODES_MAX);
+		pr_err("exceeded the maximum number of cluster nodes (%u > %u)\n",
+		       info->total_nodes, XT_CLUSTER_NODES_MAX);
 		return false;
 	}
 	if (info->node_mask >= (1ULL << info->total_nodes)) {
-		printk(KERN_ERR "xt_cluster: this node mask cannot be "
-				"higher than the total number of nodes\n");
+		pr_err("this node mask cannot be higher than the total number of nodes\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 955e659..d98b23b 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -1,6 +1,9 @@
 /* Kernel module to match connection tracking byte counter.
  * GPL (C) 2002 Martin Devera (devik@cdi.cz).
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/bitops.h>
 #include <linux/skbuff.h>
@@ -107,8 +110,8 @@ static bool connbytes_mt_check(const struct xt_mtchk_param *par)
 		return false;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_warning("can't load conntrack support for proto=%u\n",
+			   par->family);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 6809809..5a665d9 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -12,6 +12,9 @@
  * Kernel module to match connection tracking information.
  * GPL (C) 1999  Rusty Russell (rusty@rustcorp.com.au).
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/ip.h>
@@ -229,8 +232,8 @@ static bool connlimit_mt_check(const struct xt_mtchk_param *par)
 	unsigned int i;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
-		       "address family %u\n", par->family);
+		pr_warning("cannot load conntrack support for address family %u\n",
+			   par->family);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 86cacab..c7393a4 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -21,6 +21,8 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <net/netfilter/nf_conntrack.h>
@@ -66,12 +68,12 @@ static bool connmark_mt_check_v0(const struct xt_mtchk_param *par)
 	const struct xt_connmark_info *cm = par->matchinfo;
 
 	if (cm->mark > 0xffffffff || cm->mask > 0xffffffff) {
-		printk(KERN_WARNING "connmark: only support 32bit mark\n");
+		pr_warning("only support 32bit mark\n");
 		return false;
 	}
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_warning("can't load conntrack support for proto=%u\n",
+			   par->family);
 		return false;
 	}
 	return true;
@@ -80,8 +82,8 @@ static bool connmark_mt_check_v0(const struct xt_mtchk_param *par)
 static bool connmark_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
-		       "proto=%u\n", par->family);
+		pr_warning("cannot load conntrack support for proto=%u\n",
+			   par->family);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 0b7139f..40fb115 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -10,6 +10,8 @@
  *	published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <net/ipv6.h>
@@ -281,8 +283,8 @@ conntrack_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool conntrack_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_warning("can't load conntrack support for proto=%u\n",
+			   par->family);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index c3f8085..bb3caaf 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -7,6 +7,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
@@ -48,7 +50,7 @@ static bool dscp_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_dscp_info *info = par->matchinfo;
 
 	if (info->dscp > XT_DSCP_MAX) {
-		printk(KERN_ERR "xt_dscp: dscp %x out of range\n", info->dscp);
+		pr_err("dscp %x out of range\n", info->dscp);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 219dcdb..a3cac55 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -7,6 +7,9 @@
  *
  * Development of this code was funded by Astaro AG, http://www.astaro.com/
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/random.h>
@@ -156,17 +159,15 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 	if (ht->cfg.max && ht->count >= ht->cfg.max) {
 		/* FIXME: do something. question is what.. */
 		if (net_ratelimit())
-			printk(KERN_WARNING
-				"xt_hashlimit: max count of %u reached\n",
-				ht->cfg.max);
+			pr_warning("max count of %u reached\n",
+				   ht->cfg.max);
 		return NULL;
 	}
 
 	ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
 	if (!ent) {
 		if (net_ratelimit())
-			printk(KERN_ERR
-				"xt_hashlimit: can't allocate dsthash_ent\n");
+			pr_err("can't allocate dsthash_ent\n");
 		return NULL;
 	}
 	memcpy(&ent->dst, dst, sizeof(ent->dst));
@@ -205,7 +206,7 @@ static int htable_create_v0(struct xt_hashlimit_info *minfo, u_int8_t family)
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
 			sizeof(struct list_head) * size);
 	if (!hinfo) {
-		printk(KERN_ERR "xt_hashlimit: unable to create hashtable\n");
+		pr_err("unable to create hashtable\n");
 		return -1;
 	}
 	minfo->hinfo = hinfo;
@@ -277,7 +278,7 @@ static int htable_create(struct xt_hashlimit_mtinfo1 *minfo, u_int8_t family)
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
 	                sizeof(struct list_head) * size);
 	if (hinfo == NULL) {
-		printk(KERN_ERR "xt_hashlimit: unable to create hashtable\n");
+		pr_err("unable to create hashtable\n");
 		return -1;
 	}
 	minfo->hinfo = hinfo;
@@ -670,7 +671,7 @@ static bool hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 	/* Check for overflow. */
 	if (r->cfg.burst == 0 ||
 	    user2credits(r->cfg.avg * r->cfg.burst) < user2credits(r->cfg.avg)) {
-		printk(KERN_ERR "xt_hashlimit: overflow, try lower: %u/%u\n",
+		pr_err("overflow, try lower: %u/%u\n",
 		       r->cfg.avg, r->cfg.burst);
 		return false;
 	}
@@ -712,7 +713,7 @@ static bool hashlimit_mt_check(const struct xt_mtchk_param *par)
 	if (info->cfg.burst == 0 ||
 	    user2credits(info->cfg.avg * info->cfg.burst) <
 	    user2credits(info->cfg.avg)) {
-		printk(KERN_ERR "xt_hashlimit: overflow, try lower: %u/%u\n",
+		pr_err("overflow, try lower: %u/%u\n",
 		       info->cfg.avg, info->cfg.burst);
 		return false;
 	}
@@ -971,21 +972,19 @@ static int __init hashlimit_mt_init(void)
 					    sizeof(struct dsthash_ent), 0, 0,
 					    NULL);
 	if (!hashlimit_cachep) {
-		printk(KERN_ERR "xt_hashlimit: unable to create slab cache\n");
+		pr_err("unable to create slab cache\n");
 		goto err2;
 	}
 	hashlimit_procdir4 = proc_mkdir("ipt_hashlimit", init_net.proc_net);
 	if (!hashlimit_procdir4) {
-		printk(KERN_ERR "xt_hashlimit: unable to create proc dir "
-				"entry\n");
+		pr_err("unable to create proc dir entry\n");
 		goto err3;
 	}
 	err = 0;
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 	hashlimit_procdir6 = proc_mkdir("ip6t_hashlimit", init_net.proc_net);
 	if (!hashlimit_procdir6) {
-		printk(KERN_ERR "xt_hashlimit: unable to create proc dir "
-				"entry\n");
+		pr_err("unable to create proc dir entry\n");
 		err = -ENOMEM;
 	}
 #endif
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 64fc7f2..08b1c29 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -7,6 +7,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter.h>
@@ -59,8 +61,8 @@ static bool helper_mt_check(const struct xt_mtchk_param *par)
 	struct xt_helper_info *info = par->matchinfo;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->family);
+		pr_warning("can't load conntrack support for proto=%u\n",
+			   par->family);
 		return false;
 	}
 	info->name[29] = '\0';
diff --git a/net/netfilter/xt_hl.c b/net/netfilter/xt_hl.c
index 7726154..e99a838 100644
--- a/net/netfilter/xt_hl.c
+++ b/net/netfilter/xt_hl.c
@@ -10,6 +10,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/module.h>
@@ -40,8 +42,7 @@ static bool ttl_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		case IPT_TTL_GT:
 			return ttl > info->ttl;
 		default:
-			printk(KERN_WARNING "ipt_ttl: unknown mode %d\n",
-				info->mode);
+			pr_warning("unknown mode %d\n", info->mode);
 			return false;
 	}
 
@@ -67,8 +68,7 @@ static bool hl_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 			return ip6h->hop_limit > info->hop_limit;
 			break;
 		default:
-			printk(KERN_WARNING "ip6t_hl: unknown mode %d\n",
-				info->mode);
+			pr_warning("unknown mode %d\n", info->mode);
 			return false;
 	}
 
diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 501f9b6..1697770 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -8,6 +8,9 @@
  *	it under the terms of the GNU General Public License version 2 as
  *	published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ip.h>
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 2e8089e..ce3a9ea 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -6,6 +6,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
@@ -105,8 +107,8 @@ static bool limit_mt_check(const struct xt_mtchk_param *par)
 	/* Check for overflow. */
 	if (r->burst == 0
 	    || user2credits(r->avg * r->burst) < user2credits(r->avg)) {
-		printk("Overflow in xt_limit, try lower: %u/%u\n",
-		       r->avg, r->burst);
+		pr_info("Overflow in xt_limit, try lower: %u/%u\n",
+			r->avg, r->burst);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_mark.c b/net/netfilter/xt_mark.c
index 10b9e34..e2639d4 100644
--- a/net/netfilter/xt_mark.c
+++ b/net/netfilter/xt_mark.c
@@ -10,6 +10,8 @@
  *	published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 
@@ -43,7 +45,7 @@ static bool mark_mt_check_v0(const struct xt_mtchk_param *par)
 	const struct xt_mark_info *minfo = par->matchinfo;
 
 	if (minfo->mark > 0xffffffff || minfo->mask > 0xffffffff) {
-		printk(KERN_WARNING "mark: only supports 32bit mark\n");
+		pr_warning("only supports 32bit mark\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 863e409..b2e6c7f 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -17,6 +17,8 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 
@@ -379,14 +381,14 @@ static int __init xt_osf_init(void)
 
 	err = nfnetlink_subsys_register(&xt_osf_nfnetlink);
 	if (err < 0) {
-		printk(KERN_ERR "Failed (%d) to register OSF nsfnetlink helper.\n", err);
+		pr_err("Failed (%d) to register OSF nsfnetlink helper.\n", err);
 		goto err_out_exit;
 	}
 
 	err = xt_register_match(&xt_osf_match);
 	if (err) {
-		printk(KERN_ERR "Failed (%d) to register OS fingerprint "
-				"matching module.\n", err);
+		pr_err("Failed (%d) to register OS fingerprint matching module.\n",
+		       err);
 		goto err_out_remove;
 	}
 
diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index 22b2a5e..be461ff 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -11,6 +11,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/file.h>
@@ -112,9 +115,7 @@ static bool owner_mt_check_v0(const struct xt_mtchk_param *par)
 	const struct ipt_owner_info *info = par->matchinfo;
 
 	if (info->match & (IPT_OWNER_PID | IPT_OWNER_SID | IPT_OWNER_COMM)) {
-		printk(KERN_WARNING KBUILD_MODNAME
-		       ": PID, SID and command matching is not "
-		       "supported anymore\n");
+		pr_warning("PID, SID and command matching is not supported anymore\n");
 		return false;
 	}
 
@@ -126,8 +127,7 @@ static bool owner_mt6_check_v0(const struct xt_mtchk_param *par)
 	const struct ip6t_owner_info *info = par->matchinfo;
 
 	if (info->match & (IP6T_OWNER_PID | IP6T_OWNER_SID)) {
-		printk(KERN_WARNING KBUILD_MODNAME
-		       ": PID and SID matching is not supported anymore\n");
+		pr_warning("PID and SID matching is not supported anymore\n");
 		return false;
 	}
 
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 8d28ca5..19354b6 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -8,6 +8,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter_bridge.h>
@@ -95,9 +97,9 @@ static bool physdev_mt_check(const struct xt_mtchk_param *par)
 	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&
 	    par->hook_mask & ((1 << NF_INET_LOCAL_OUT) |
 	    (1 << NF_INET_FORWARD) | (1 << NF_INET_POST_ROUTING))) {
-		printk(KERN_WARNING "physdev match: using --physdev-out in the "
-		       "OUTPUT, FORWARD and POSTROUTING chains for non-bridged "
-		       "traffic is not supported anymore.\n");
+		pr_warning("using --physdev-out in the "
+			   "OUTPUT, FORWARD and POSTROUTING chains for non-bridged "
+			   "traffic is not supported anymore.\n");
 		if (par->hook_mask & (1 << NF_INET_LOCAL_OUT))
 			return false;
 	}
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 4cbfebd..283e0f3 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -7,6 +7,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -133,24 +135,21 @@ static bool policy_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_policy_info *info = par->matchinfo;
 
 	if (!(info->flags & (XT_POLICY_MATCH_IN|XT_POLICY_MATCH_OUT))) {
-		printk(KERN_ERR "xt_policy: neither incoming nor "
-				"outgoing policy selected\n");
+		pr_err("neither incoming nor outgoing policy selected\n");
 		return false;
 	}
 	if (par->hook_mask & ((1 << NF_INET_PRE_ROUTING) |
 	    (1 << NF_INET_LOCAL_IN)) && info->flags & XT_POLICY_MATCH_OUT) {
-		printk(KERN_ERR "xt_policy: output policy not valid in "
-				"PRE_ROUTING and INPUT\n");
+		pr_err("output policy not valid in PRE_ROUTING and INPUT\n");
 		return false;
 	}
 	if (par->hook_mask & ((1 << NF_INET_POST_ROUTING) |
 	    (1 << NF_INET_LOCAL_OUT)) && info->flags & XT_POLICY_MATCH_IN) {
-		printk(KERN_ERR "xt_policy: input policy not valid in "
-				"POST_ROUTING and OUTPUT\n");
+		pr_err("input policy not valid in POST_ROUTING and OUTPUT\n");
 		return false;
 	}
 	if (info->len > XT_POLICY_MAX_ELEM) {
-		printk(KERN_ERR "xt_policy: too many policy elements\n");
+		pr_err("too many policy elements\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index eb0ceb8..f7715a6 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -12,6 +12,9 @@
  * Author: Stephen Frost <sfrost@snowman.net>
  * Copyright 2002-2003, Stephen Frost, 2.5.x port by laforge@netfilter.org
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/init.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -459,8 +462,8 @@ static int recent_old_seq_open(struct inode *inode, struct file *filp)
 	static bool warned_of_old;
 
 	if (unlikely(!warned_of_old)) {
-		printk(KERN_INFO KBUILD_MODNAME ": Use of /proc/net/ipt_recent"
-		       " is deprecated; use /proc/net/xt_recent.\n");
+		pr_info("Use of /proc/net/ipt_recent is deprecated; "
+			"use /proc/net/xt_recent.\n");
 		warned_of_old = true;
 	}
 	return recent_seq_open(inode, filp);
@@ -568,7 +571,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 		add = true;
 		break;
 	default:
-		printk(KERN_INFO KBUILD_MODNAME ": Need +ip, -ip or /\n");
+		pr_info("Need +ip, -ip or /\n");
 		return -EINVAL;
 	}
 
@@ -583,8 +586,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 	}
 
 	if (!succ) {
-		printk(KERN_INFO KBUILD_MODNAME ": illegal address written "
-		       "to procfs\n");
+		pr_info("illegal address written to procfs\n");
 		return -EINVAL;
 	}
 
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index ebf00ad..7fee096 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -10,6 +10,8 @@
  *
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter/x_tables.h>
@@ -165,8 +167,7 @@ socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
 			sk = NULL;
 	}
 
-	pr_debug("socket match: proto %u %08x:%u -> %08x:%u "
-		 "(orig %08x:%u) sock %p\n",
+	pr_debug("proto %u %08x:%u -> %08x:%u (orig %08x:%u) sock %p\n",
 		 protocol, ntohl(saddr), ntohs(sport),
 		 ntohl(daddr), ntohs(dport),
 		 ntohl(iph->daddr), hp ? ntohs(hp->dest) : 0, sk);
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 4c946cb..0f42ca3 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -8,6 +8,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <net/netfilter/nf_conntrack.h>
@@ -40,8 +42,8 @@ state_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool state_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->match->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->match->family);
+		pr_warning("can't load conntrack support for proto=%u\n",
+			   par->match->family);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index d8c0f8f..8d63821 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -8,6 +8,8 @@
  * Based on ipt_random and ipt_nth by Fabrice MARIE <fabrice@netfilter.org>.
  */
 
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/init.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
@@ -62,7 +64,7 @@ static bool statistic_mt_check(const struct xt_mtchk_param *par)
 
 	info->master = kzalloc(sizeof(*info->master), GFP_KERNEL);
 	if (info->master == NULL) {
-		printk(KERN_ERR KBUILD_MODNAME ": Out of memory\n");
+		pr_err("Out of memory\n");
 		return false;
 	}
 	info->master->count = info->u.nth.count;
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 93acaa5..e9f61b9 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -10,6 +10,9 @@
  *	This file is distributed under the terms of the GNU General Public
  *	License (GPL). Copies of the GPL can be obtained from gnu.org/gpl.
  */
+
+#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
+
 #include <linux/ktime.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -224,8 +227,7 @@ static bool time_mt_check(const struct xt_mtchk_param *par)
 
 	if (info->daytime_start > XT_TIME_MAX_DAYTIME ||
 	    info->daytime_stop > XT_TIME_MAX_DAYTIME) {
-		printk(KERN_WARNING "xt_time: invalid argument - start or "
-		       "stop time greater than 23:59:59\n");
+		pr_warning("invalid argument - start or stop time greater than 23:59:59\n");
 		return false;
 	}
 
@@ -246,13 +248,11 @@ static int __init time_mt_init(void)
 	int minutes = sys_tz.tz_minuteswest;
 
 	if (minutes < 0) /* east of Greenwich */
-		printk(KERN_INFO KBUILD_MODNAME
-		       ": kernel timezone is +%02d%02d\n",
-		       -minutes / 60, -minutes % 60);
+		pr_info("kernel timezone is +%02d%02d\n",
+			-minutes / 60, -minutes % 60);
 	else /* west of Greenwich */
-		printk(KERN_INFO KBUILD_MODNAME
-		       ": kernel timezone is -%02d%02d\n",
-		       minutes / 60, minutes % 60);
+		pr_info("kernel timezone is -%02d%02d\n",
+			minutes / 60, minutes % 60);
 
 	return xt_register_match(&xt_time_mt_reg);
 }
-- 
1.6.3.1.10.g659a0.dirty

