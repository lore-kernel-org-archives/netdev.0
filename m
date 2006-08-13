From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 16/16] [RTNETLINK]: Unexport rtnl socket
Date: Mon, 14 Aug 2006 00:00:16 +0200
Message-ID: <20060814214344.096247898@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:26574 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964993AbWHNVpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:45:38 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=unexport_rtnl
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/linux/rtnetlink.h
===================================================================
--- net-2.6.19.git.orig/include/linux/rtnetlink.h
+++ net-2.6.19.git/include/linux/rtnetlink.h
@@ -574,8 +574,6 @@ extern int rtattr_parse(struct rtattr *t
 #define rtattr_parse_nested(tb, max, rta) \
 	rtattr_parse((tb), (max), RTA_DATA((rta)), RTA_PAYLOAD((rta)))
 
-extern struct sock *rtnl;
-
 struct rtnetlink_link
 {
 	int (*doit)(struct sk_buff *, struct nlmsghdr*, void *attr);
Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -58,6 +58,7 @@
 #endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
 static DEFINE_MUTEX(rtnl_mutex);
+static struct sock *rtnl;
 
 void rtnl_lock(void)
 {
@@ -95,8 +96,6 @@ int rtattr_parse(struct rtattr *tb[], in
 	return 0;
 }
 
-struct sock *rtnl;
-
 struct rtnetlink_link * rtnetlink_links[NPROTO];
 
 static const int rtm_min[RTM_NR_FAMILIES] =
@@ -842,7 +841,6 @@ EXPORT_SYMBOL(rtattr_strlcpy);
 EXPORT_SYMBOL(rtattr_parse);
 EXPORT_SYMBOL(rtnetlink_links);
 EXPORT_SYMBOL(rtnetlink_put_metrics);
-EXPORT_SYMBOL(rtnl);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);
 EXPORT_SYMBOL(rtnl_unlock);

