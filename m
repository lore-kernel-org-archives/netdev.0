From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 07/12] [PKT_SCHED] cls: Use rtnl registration interface
Date: Thu, 22 Mar 2007 14:00:02 +0100
Message-ID: <20070322130058.085424773@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53656 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707AbXCVNCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:02:01 -0400
Content-Disposition: inline; filename=rtnl_reg_cls_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/sched/cls_api.c
===================================================================
--- net-2.6.22.orig/net/sched/cls_api.c	2007-03-22 13:23:14.000000000 +0100
+++ net-2.6.22/net/sched/cls_api.c	2007-03-22 13:23:58.000000000 +0100
@@ -29,7 +29,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <linux/netlink.h>
@@ -616,18 +615,11 @@ rtattr_failure: __attribute__ ((unused))
 
 static int __init tc_filter_init(void)
 {
-	struct rtnetlink_link *link_p = rtnetlink_links[PF_UNSPEC];
+	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, tc_ctl_tfilter, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETTFILTER, tc_ctl_tfilter,
+						 tc_dump_tfilter);
 
-	/* Setup rtnetlink links. It is made here to avoid
-	   exporting large number of public symbols.
-	 */
-
-	if (link_p) {
-		link_p[RTM_NEWTFILTER-RTM_BASE].doit = tc_ctl_tfilter;
-		link_p[RTM_DELTFILTER-RTM_BASE].doit = tc_ctl_tfilter;
-		link_p[RTM_GETTFILTER-RTM_BASE].doit = tc_ctl_tfilter;
-		link_p[RTM_GETTFILTER-RTM_BASE].dumpit = tc_dump_tfilter;
-	}
 	return 0;
 }
 

--

