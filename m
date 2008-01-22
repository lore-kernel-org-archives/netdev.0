From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] [IPV6,IPV4]: Fix several sparse warnings.
Date: Tue, 22 Jan 2008 18:56:32 +0900 (JST)
Message-ID: <20080122.185632.09970660.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38325 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761564AbYAVJ4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 04:56:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, please consider pulling following changes on top of net-2.6.25 tree:
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6-dev-20080122

Thank you.

HEADLINES
---------

    [IPV4] UDP,UDPLITE: Sparse: {__udp4_lib,udp,udplite}_err() are of void.
    [IPV6] UDP,UDPLITE: Sparse: {__udp6_lib,udp,udplite}_err() are of void.
    [IPV6] UDPLITE: Sparse: Declare non-static symbols in header.
    [IPV6] ADDRLABEL: Sparse: Make several functions static.
    [IPV6]: Sparse: Declare non-static ipv6_{route,icmp,frag}_sysctl_init() in header.
    [IPV6] ADDRCONF: Sparse: Make inet6_dump_addr() code paths more straight-forward.
    [IPV6] NDISC: Sparse: Use different variable name for local use.

DIFFSTAT
--------

 include/net/ipv6.h         |    4 ++++
 net/ipv4/udp.c             |    2 +-
 net/ipv4/udplite.c         |    2 +-
 net/ipv6/addrconf.c        |   38 ++++++++++++++++++--------------------
 net/ipv6/addrlabel.c       |   20 ++++++++++----------
 net/ipv6/af_inet6.c        |    2 --
 net/ipv6/ndisc.c           |   10 +++++-----
 net/ipv6/sysctl_net_ipv6.c |    3 ---
 net/ipv6/udp.c             |    2 +-
 net/ipv6/udp_impl.h        |    1 +
 net/ipv6/udplite.c         |    2 +-
 11 files changed, 42 insertions(+), 44 deletions(-)

CHANGESETS
----------

commit 9c14555fec7d209c90ae5079c59dc9a338620fd7
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Jan 22 17:05:31 2008 +0900

    [IPV4] UDP,UDPLITE: Sparse: {__udp4_lib,udp,udplite}_err() are of void.
    
    Fix following sparse warnings:
    | net/ipv4/udp.c:421:2: warning: returning void-valued expression
    | net/ipv4/udplite.c:38:2: warning: returning void-valued expression
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cb2411c..ecd9d91 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -418,7 +418,7 @@ out:
 
 void udp_err(struct sk_buff *skb, u32 info)
 {
-	return __udp4_lib_err(skb, info, udp_hash);
+	__udp4_lib_err(skb, info, udp_hash);
 }
 
 /*
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index f5baeb3..001b881 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -35,7 +35,7 @@ static int udplite_rcv(struct sk_buff *skb)
 
 static void udplite_err(struct sk_buff *skb, u32 info)
 {
-	return __udp4_lib_err(skb, info, udplite_hash);
+	__udp4_lib_err(skb, info, udplite_hash);
 }
 
 static	struct net_protocol udplite_protocol = {

---
commit feafbe254cd11496370192a08dbdc1d0ddda226f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Jan 22 17:09:55 2008 +0900

    [IPV6] UDP,UDPLITE: Sparse: {__udp6_lib,udp,udplite}_err() are of void.
    
    Fix following sparse warnings:
    | net/ipv6/udp.c:262:2: warning: returning void-valued expression
    | net/ipv6/udplite.c:29:2: warning: returning void-valued expression
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index bf58aca..bd4b9df 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -259,7 +259,7 @@ static __inline__ void udpv6_err(struct sk_buff *skb,
 				 struct inet6_skb_parm *opt, int type,
 				 int code, int offset, __be32 info     )
 {
-	return __udp6_lib_err(skb, opt, type, code, offset, info, udp_hash);
+	__udp6_lib_err(skb, opt, type, code, offset, info, udp_hash);
 }
 
 int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 39f0705..87d4202 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -26,7 +26,7 @@ static void udplitev6_err(struct sk_buff *skb,
 			  struct inet6_skb_parm *opt,
 			  int type, int code, int offset, __be32 info)
 {
-	return __udp6_lib_err(skb, opt, type, code, offset, info, udplite_hash);
+	__udp6_lib_err(skb, opt, type, code, offset, info, udplite_hash);
 }
 
 static struct inet6_protocol udplitev6_protocol = {

---
commit ce97db1c7fa125b3f24a3d424a6373824a0bca37
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Jan 22 17:25:46 2008 +0900

    [IPV6] UDPLITE: Sparse: Declare non-static symbols in header.
    
    Fix the following sparse warnings:
    | net/ipv6/udplite.c:45:14: warning: symbol 'udplitev6_prot' was not declared. Should it be static?
    | net/ipv6/udplite.c:80:12: warning: symbol 'udplitev6_init' was not declared. Should it be static?
    | net/ipv6/udplite.c:99:6: warning: symbol 'udplitev6_exit' was not declared. Should it be static?
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 2d3fda6..21be3a8 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -5,6 +5,7 @@
 #include <net/protocol.h>
 #include <net/addrconf.h>
 #include <net/inet_common.h>
+#include <net/transp_v6.h>
 
 extern int  	__udp6_lib_rcv(struct sk_buff *, struct hlist_head [], int );
 extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,

---
commit c70651db4683cdaec05d83b91b6a53560f045a27
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Jan 22 17:12:50 2008 +0900

    [IPV6] ADDRLABEL: Sparse: Make several functions static.
    
    Fix following sparse warnings:
    | net/ipv6/addrlabel.c:172:25: warning: symbol 'ip6addrlbl_alloc' was not declared. Should it be static?
    | net/ipv6/addrlabel.c:219:5: warning: symbol '__ip6addrlbl_add' was not declared. Should it be static?
    | net/ipv6/addrlabel.c:260:5: warning: symbol 'ip6addrlbl_add' was not declared. Should it be static?
    | net/ipv6/addrlabel.c:285:5: warning: symbol '__ip6addrlbl_del' was not declared. Should it be static?
    | net/ipv6/addrlabel.c:311:5: warning: symbol 'ip6addrlbl_del' was not declared. Should it be static?
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 6f1ca60..3867412 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -169,9 +169,9 @@ u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
 }
 
 /* allocate one entry */
-struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
-					  int prefixlen, int ifindex,
-					  u32 label)
+static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
+						 int prefixlen, int ifindex,
+						 u32 label)
 {
 	struct ip6addrlbl_entry *newp;
 	int addrtype;
@@ -216,7 +216,7 @@ struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
 }
 
 /* add a label */
-int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
+static int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
 {
 	int ret = 0;
 
@@ -257,8 +257,8 @@ out:
 }
 
 /* add a label */
-int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
-		       int ifindex, u32 label, int replace)
+static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
+			  int ifindex, u32 label, int replace)
 {
 	struct ip6addrlbl_entry *newp;
 	int ret = 0;
@@ -282,8 +282,8 @@ int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
 }
 
 /* remove a label */
-int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
-			  int ifindex)
+static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+			    int ifindex)
 {
 	struct ip6addrlbl_entry *p = NULL;
 	struct hlist_node *pos, *n;
@@ -308,8 +308,8 @@ int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 	return ret;
 }
 
-int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
-		       int ifindex)
+static int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+			  int ifindex)
 {
 	struct in6_addr prefix_buf;
 	int ret;

---
commit 50207356bc5026b53dbf99a3e86c28a683ae6745
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Jan 22 17:18:38 2008 +0900

    [IPV6]: Sparse: Declare non-static ipv6_{route,icmp,frag}_sysctl_init() in header.
    
    Fix the following sparse warnings:
    | net/ipv6/route.c:2491:18: warning: symbol 'ipv6_route_sysctl_init' was not declared. Should it be static?
    | net/ipv6/icmp.c:922:18: warning: symbol 'ipv6_icmp_sysctl_init' was not declared. Should it be static?
    | net/ipv6/reassembly.c:628:6: warning: symbol 'ipv6_frag_sysctl_init' was not declared. Should it be static?
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c8e8cb2..3712cae 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -586,6 +586,10 @@ extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 			 int __user *optlen);
 
 #ifdef CONFIG_PROC_FS
+extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
+extern void ipv6_frag_sysctl_init(struct net *net);
+extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
+
 extern int  ac6_proc_init(void);
 extern void ac6_proc_exit(void);
 extern int  raw6_proc_init(void);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3150c4b..6738a7b 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -72,8 +72,6 @@ MODULE_LICENSE("GPL");
 static struct list_head inetsw6[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw6_lock);
 
-void ipv6_frag_sysctl_init(struct net *net);
-
 static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
 	const int offset = sk->sk_prot->obj_size - sizeof(struct ipv6_pinfo);
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 5e0af4d..7197eb7 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -14,9 +14,6 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
-extern struct ctl_table *ipv6_route_sysctl_init(struct net *net);
-extern struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
-
 static ctl_table ipv6_table_template[] = {
 	{
 		.ctl_name	= NET_IPV6_ROUTE,

---
commit 2aa6b4e605b700e10943afd9f34cd0527304f3a3
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Jan 22 17:29:40 2008 +0900

    [IPV6] ADDRCONF: Sparse: Make inet6_dump_addr() code paths more straight-forward.
    
    Fix the following sparse warning:
    | net/ipv6/addrconf.c:3384:2: warning: context imbalance in 'inet6_dump_addr' - different lock contexts for basic block
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index aba7b5d..e40213d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3335,11 +3335,11 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 			     ifa = ifa->if_next, ip_idx++) {
 				if (ip_idx < s_ip_idx)
 					continue;
-				if ((err = inet6_fill_ifaddr(skb, ifa,
-				    NETLINK_CB(cb->skb).pid,
-				    cb->nlh->nlmsg_seq, RTM_NEWADDR,
-				    NLM_F_MULTI)) <= 0)
-					goto done;
+				err = inet6_fill_ifaddr(skb, ifa,
+							NETLINK_CB(cb->skb).pid,
+							cb->nlh->nlmsg_seq,
+							RTM_NEWADDR,
+							NLM_F_MULTI);
 			}
 			break;
 		case MULTICAST_ADDR:
@@ -3348,11 +3348,11 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 			     ifmca = ifmca->next, ip_idx++) {
 				if (ip_idx < s_ip_idx)
 					continue;
-				if ((err = inet6_fill_ifmcaddr(skb, ifmca,
-				    NETLINK_CB(cb->skb).pid,
-				    cb->nlh->nlmsg_seq, RTM_GETMULTICAST,
-				    NLM_F_MULTI)) <= 0)
-					goto done;
+				err = inet6_fill_ifmcaddr(skb, ifmca,
+							  NETLINK_CB(cb->skb).pid,
+							  cb->nlh->nlmsg_seq,
+							  RTM_GETMULTICAST,
+							  NLM_F_MULTI);
 			}
 			break;
 		case ANYCAST_ADDR:
@@ -3361,11 +3361,11 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 			     ifaca = ifaca->aca_next, ip_idx++) {
 				if (ip_idx < s_ip_idx)
 					continue;
-				if ((err = inet6_fill_ifacaddr(skb, ifaca,
-				    NETLINK_CB(cb->skb).pid,
-				    cb->nlh->nlmsg_seq, RTM_GETANYCAST,
-				    NLM_F_MULTI)) <= 0)
-					goto done;
+				err = inet6_fill_ifacaddr(skb, ifaca,
+							  NETLINK_CB(cb->skb).pid,
+							  cb->nlh->nlmsg_seq,
+							  RTM_GETANYCAST,
+							  NLM_F_MULTI);
 			}
 			break;
 		default:
@@ -3373,14 +3373,12 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 		}
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
+
+		if (err <= 0)
+			break;
 cont:
 		idx++;
 	}
-done:
-	if (err <= 0) {
-		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
-	}
 	cb->args[0] = idx;
 	cb->args[1] = ip_idx;
 	return skb->len;

---
commit b825a8d0e0d210bffeec948b1790c3be4c3c5448
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Jan 22 17:32:53 2008 +0900

    [IPV6] NDISC: Sparse: Use different variable name for local use.
    
    Fix the following sparse warnings:
    | net/ipv6/ndisc.c:1300:21: warning: symbol 'opt' shadows an earlier one
    | net/ipv6/ndisc.c:1078:7: originally declared here
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e1554ba..92b6775 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1297,11 +1297,11 @@ skip_defrtr:
 	}
 
 	if (ndopts.nd_useropts) {
-		struct nd_opt_hdr *opt;
-		for (opt = ndopts.nd_useropts;
-		     opt;
-		     opt = ndisc_next_useropt(opt, ndopts.nd_useropts_end)) {
-				ndisc_ra_useropt(skb, opt);
+		struct nd_opt_hdr *p;
+		for (p = ndopts.nd_useropts;
+		     p;
+		     p = ndisc_next_useropt(p, ndopts.nd_useropts_end)) {
+			ndisc_ra_useropt(skb, p);
 		}
 	}
 

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
