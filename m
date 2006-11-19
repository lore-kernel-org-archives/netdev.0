From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] [DECnet] address: Rename rtmsg_ifa() to dn_ifaddr_notify()
Date: Sun, 19 Nov 2006 23:23:28 +0100
Message-ID: <20061119222420.251142807@lsx.localdomain>
References: <20061119222326.208529546@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:7095 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933470AbWKSWZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 17:25:34 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_dn_notify
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The name rtmsg_ifa is heavly overused and confusing.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/net/decnet/dn_dev.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_dev.c	2006-11-19 18:33:43.000000000 +0100
+++ net-2.6.20/net/decnet/dn_dev.c	2006-11-19 18:36:45.000000000 +0100
@@ -73,7 +73,7 @@
 
 static struct dn_dev *dn_dev_create(struct net_device *dev, int *err);
 static void dn_dev_delete(struct net_device *dev);
-static void rtmsg_ifa(int event, struct dn_ifaddr *ifa);
+static void dn_ifaddr_notify(int event, struct dn_ifaddr *ifa);
 
 static int dn_eth_up(struct net_device *);
 static void dn_eth_down(struct net_device *);
@@ -442,7 +442,7 @@
 		}
 	}
 
-	rtmsg_ifa(RTM_DELADDR, ifa1);
+	dn_ifaddr_notify(RTM_DELADDR, ifa1);
 	blocking_notifier_call_chain(&dnaddr_chain, NETDEV_DOWN, ifa1);
 	if (destroy) {
 		dn_dev_free_ifa(ifa1);
@@ -477,7 +477,7 @@
 	ifa->ifa_next = dn_db->ifa_list;
 	dn_db->ifa_list = ifa;
 
-	rtmsg_ifa(RTM_NEWADDR, ifa);
+	dn_ifaddr_notify(RTM_NEWADDR, ifa);
 	blocking_notifier_call_chain(&dnaddr_chain, NETDEV_UP, ifa);
 
 	return 0;
@@ -751,7 +751,7 @@
         return -1;
 }
 
-static void rtmsg_ifa(int event, struct dn_ifaddr *ifa)
+static void dn_ifaddr_notify(int event, struct dn_ifaddr *ifa)
 {
 	struct sk_buff *skb;
 	int err = -ENOBUFS;

--

