From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 08/12] [PKT_SCHED] act: Use rtnl registration interface
Date: Wed, 21 Mar 2007 01:06:01 +0100
Message-ID: <20070321000710.276893953@lsx.localdomain>
References: <20070321000553.070942307@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44411 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306AbXCUAmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:42:10 -0400
Content-Disposition: inline; filename=rtnl_reg_act_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/sched/act_api.c
===================================================================
--- net-2.6.22.orig/net/sched/act_api.c	2007-03-20 23:53:20.000000000 +0100
+++ net-2.6.22/net/sched/act_api.c	2007-03-21 00:52:37.000000000 +0100
@@ -25,7 +25,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <net/sock.h>
@@ -940,7 +939,7 @@ done:
 	return ret;
 }
 
-static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int nl_act_modify(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct rtattr **tca = arg;
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
@@ -1012,8 +1011,7 @@ find_dump_kind(struct nlmsghdr *n)
 	return kind;
 }
 
-static int
-tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl_act_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
@@ -1077,14 +1075,9 @@ nlmsg_failure:
 
 static int __init tc_action_init(void)
 {
-	struct rtnetlink_link *link_p = rtnetlink_links[PF_UNSPEC];
-
-	if (link_p) {
-		link_p[RTM_NEWACTION-RTM_BASE].doit = tc_ctl_action;
-		link_p[RTM_DELACTION-RTM_BASE].doit = tc_ctl_action;
-		link_p[RTM_GETACTION-RTM_BASE].doit = tc_ctl_action;
-		link_p[RTM_GETACTION-RTM_BASE].dumpit = tc_dump_action;
-	}
+	rtnl_register(PF_UNSPEC, RTM_NEWACTION, nl_act_modify, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELACTION, nl_act_modify, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETACTION, nl_act_modify, nl_act_dump);
 
 	return 0;
 }

--

