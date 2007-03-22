From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 02/12] [NET] link: Use rtnl registration interface
Date: Thu, 22 Mar 2007 13:59:57 +0100
Message-ID: <20070322130057.397316899@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53639 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbXCVNBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:01:35 -0400
Content-Disposition: inline; filename=rtnl_reg_core_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-03-22 12:48:20.000000000 +0100
+++ net-2.6.22/net/core/rtnetlink.c	2007-03-22 12:49:31.000000000 +0100
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
+	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink, rtnl_dump_ifinfo);
+	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL);
 }
 
 EXPORT_SYMBOL(__rta_fill);

--

