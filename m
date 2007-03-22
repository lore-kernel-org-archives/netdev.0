From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 08/12] [PKT_SCHED] act: Use rtnl registration interface
Date: Thu, 22 Mar 2007 14:00:03 +0100
Message-ID: <20070322130058.227136510@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53659 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608AbXCVNCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:02:06 -0400
Content-Disposition: inline; filename=rtnl_reg_act_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/sched/act_api.c
===================================================================
--- net-2.6.22.orig/net/sched/act_api.c	2007-03-22 13:23:13.000000000 +0100
+++ net-2.6.22/net/sched/act_api.c	2007-03-22 13:23:59.000000000 +0100
@@ -25,7 +25,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <net/sock.h>
@@ -1077,14 +1076,9 @@ nlmsg_failure:
 
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
+	rtnl_register(PF_UNSPEC, RTM_NEWACTION, tc_ctl_action, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELACTION, tc_ctl_action, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETACTION, tc_ctl_action, tc_dump_action);
 
 	return 0;
 }

--

