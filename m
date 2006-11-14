From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [GENL]: Add genlmsg_new() to allocate generic netlink messages
Date: Tue, 14 Nov 2006 12:46:29 +0100
Message-ID: <20061114114657.681000534@lsx.localdomain>
References: <20061114114628.033840590@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:25276 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933419AbWKNLsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 06:48:06 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=genlmsg_new
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/genetlink.h
===================================================================
--- net-2.6.20.orig/include/net/genetlink.h	2006-11-14 11:52:29.000000000 +0100
+++ net-2.6.20/include/net/genetlink.h	2006-11-14 12:23:56.000000000 +0100
@@ -187,4 +187,15 @@
 	return NLMSG_ALIGN(genlmsg_msg_size(payload));
 }
 
+/**
+ * genlmsg_new - Allocate a new generic netlink message
+ * @payload: size of the message payload
+ * @flags: the type of memory to allocate.
+ */
+static inline struct sk_buff *genlmsg_new(size_t payload, gfp_t flags)
+{
+	return nlmsg_new(genlmsg_total_size(payload), flags);
+}
+
+
 #endif	/* __NET_GENERIC_NETLINK_H */
Index: net-2.6.20/kernel/taskstats.c
===================================================================
--- net-2.6.20.orig/kernel/taskstats.c	2006-11-14 11:53:44.000000000 +0100
+++ net-2.6.20/kernel/taskstats.c	2006-11-14 12:23:18.000000000 +0100
@@ -77,7 +77,7 @@
 	/*
 	 * If new attributes are added, please revisit this allocation
 	 */
-	skb = nlmsg_new(genlmsg_total_size(size), GFP_KERNEL);
+	skb = genlmsg_new(size, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 

--

