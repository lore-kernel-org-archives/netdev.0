From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ipv4 addr: Send netlink notification for address label changes
Date: Thu, 5 Jun 2008 02:02:03 +0200
Message-ID: <20080605000203.GK20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60723 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759848AbYFEABv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 20:01:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes people happy who try to keep a list of addresses up to date
by listening to notifications.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv4/devinet.c
===================================================================
--- net-2.6.orig/net/ipv4/devinet.c	2008-06-04 23:14:26.000000000 +0200
+++ net-2.6/net/ipv4/devinet.c	2008-06-05 01:56:41.000000000 +0200
@@ -1013,7 +1013,7 @@
 		memcpy(old, ifa->ifa_label, IFNAMSIZ);
 		memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 		if (named++ == 0)
-			continue;
+			goto skip;
 		dot = strchr(old, ':');
 		if (dot == NULL) {
 			sprintf(old, ":%d", named);
@@ -1024,6 +1024,8 @@
 		} else {
 			strcpy(ifa->ifa_label + (IFNAMSIZ - strlen(dot) - 1), dot);
 		}
+skip:
+		rtmsg_ifa(RTM_NEWADDR, ifa, NULL, 0);
 	}
 }
 
