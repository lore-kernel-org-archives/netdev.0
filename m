From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 12/12] [RTNL]: Use rtnl registration interface for dump-all aliases
Date: Thu, 22 Mar 2007 14:00:07 +0100
Message-ID: <20070322130058.825241121@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53672 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbXCVNC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:02:26 -0400
Content-Disposition: inline; filename=rtnl_reg_dump_all
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-22 13:23:11.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-22 13:24:04.000000000 +0100
@@ -958,12 +958,6 @@ static void rtnetlink_rcv(struct sock *s
 	} while (qlen);
 }
 
-static struct rtnetlink_link link_rtnetlink_table[RTM_NR_MSGTYPES] =
-{
-	[RTM_GETADDR     - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
-	[RTM_GETROUTE    - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
-};
-
 static int rtnetlink_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
@@ -1013,6 +1007,9 @@ void __init rtnetlink_init(void)
 
 	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink, rtnl_dump_ifinfo);
 	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL);
+
+	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all);
+	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all);
 }
 
 EXPORT_SYMBOL(__rta_fill);

--

