From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: [NET]: Use BUILD_BUG_ON() for checking size of skb->cb.
Date: Sat, 26 Aug 2006 21:19:26 +0900 (JST)
Message-ID: <20060826.211926.115316425.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:22795 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964943AbWHZMRg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 08:17:36 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Use BUILD_BUG_ON() for checking size of skb->cb.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c84a320..8f11a34 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1254,10 +1254,7 @@ static int __init inet_init(void)
 	struct list_head *r;
 	int rc = -EINVAL;
 
-	if (sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb)) {
-		printk(KERN_CRIT "%s: panic\n", __FUNCTION__);
-		goto out;
-	}
+	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb));
 
 	rc = proto_register(&tcp_prot, 1);
 	if (rc)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index ac85e9c..b77726e 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -757,6 +757,8 @@ static int __init inet6_init(void)
         struct list_head *r;
 	int err;
 
+	BUILD_BUG_ON(sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb));
+
 #ifdef MODULE
 #if 0 /* FIXME --RR */
 	if (!mod_member_present(&__this_module, can_unload))
@@ -766,11 +768,6 @@ #if 0 /* FIXME --RR */
 #endif
 #endif
 
-	if (sizeof(struct inet6_skb_parm) > sizeof(dummy_skb->cb)) {
-		printk(KERN_CRIT "inet6_proto_init: size fault\n");
-		return -EINVAL;
-	}
-
 	err = proto_register(&tcpv6_prot, 1);
 	if (err)
 		goto out;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index b85c1f9..f3d63a5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1728,8 +1728,6 @@ static struct net_proto_family netlink_f
 	.owner	= THIS_MODULE,	/* for consistency 8) */
 };
 
-extern void netlink_skb_parms_too_large(void);
-
 static int __init netlink_proto_init(void)
 {
 	struct sk_buff *dummy_skb;
@@ -1741,8 +1739,7 @@ static int __init netlink_proto_init(voi
 	if (err != 0)
 		goto out;
 
-	if (sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb))
-		netlink_skb_parms_too_large();
+	BUILD_BUG_ON(sizeof(struct netlink_skb_parms) > sizeof(dummy_skb->cb));
 
 	nl_table = kcalloc(MAX_LINKS, sizeof(*nl_table), GFP_KERNEL);
 	if (!nl_table) {
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index de6ec51..7c91c20 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2060,10 +2060,7 @@ static int __init af_unix_init(void)
 	int rc = -1;
 	struct sk_buff *dummy_skb;
 
-	if (sizeof(struct unix_skb_parms) > sizeof(dummy_skb->cb)) {
-		printk(KERN_CRIT "%s: panic\n", __FUNCTION__);
-		goto out;
-	}
+	BUILD_BUG_ON(sizeof(struct unix_skb_parms) > sizeof(dummy_skb->cb));
 
 	rc = proto_register(&unix_proto, 1);
         if (rc != 0) {

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
