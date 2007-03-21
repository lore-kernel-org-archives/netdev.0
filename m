From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 02/12] [NET] link: Use rtnl registration interface
Date: Wed, 21 Mar 2007 01:05:55 +0100
Message-ID: <20070321000709.464778832@lsx.localdomain>
References: <20070321000553.070942307@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44410 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbXCUAmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:42:10 -0400
Content-Disposition: inline; filename=rtnl_reg_core_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-21 00:52:26.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-21 00:52:28.000000000 +0100
@@ -537,7 +537,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->args[0];
@@ -568,7 +568,7 @@ static struct nla_policy ifla_policy[IFL
 	[IFLA_LINKMODE]		= { .type = NLA_U8 },
 };
 
-static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int nl_link_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct ifinfomsg *ifm;
 	struct net_device *dev;
@@ -738,7 +738,7 @@ errout:
 	return err;
 }
 
-static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int nl_link_get(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct ifinfomsg *ifm;
 	struct nlattr *tb[IFLA_MAX+1];
@@ -960,9 +960,6 @@ static void rtnetlink_rcv(struct sock *s
 
 static struct rtnetlink_link link_rtnetlink_table[RTM_NR_MSGTYPES] =
 {
-	[RTM_GETLINK     - RTM_BASE] = { .doit   = rtnl_getlink,
-					 .dumpit = rtnl_dump_ifinfo	 },
-	[RTM_SETLINK     - RTM_BASE] = { .doit   = rtnl_setlink		 },
 	[RTM_GETADDR     - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
 	[RTM_GETROUTE    - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
 	[RTM_NEWNEIGH    - RTM_BASE] = { .doit   = neigh_add		 },
@@ -1023,8 +1020,9 @@ void __init rtnetlink_init(void)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
 	register_netdevice_notifier(&rtnetlink_dev_notifier);
-	rtnetlink_links[PF_UNSPEC] = link_rtnetlink_table;
-	rtnetlink_links[PF_PACKET] = link_rtnetlink_table;
+
+	rtnl_register(PF_UNSPEC, RTM_GETLINK, nl_link_get, nl_link_dump);
+	rtnl_register(PF_UNSPEC, RTM_SETLINK, nl_link_set, NULL);
 }
 
 EXPORT_SYMBOL(__rta_fill);

--

