From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] [GENL]: Add genlmsg_reply() to simply unicast replies to requests
Date: Tue, 14 Nov 2006 12:46:30 +0100
Message-ID: <20061114114657.817678128@lsx.localdomain>
References: <20061114114628.033840590@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:26300 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933417AbWKNLsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 06:48:11 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=genlmsg_reply
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A generic netlink user has no interest in knowing how to
address the source of the original request.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/genetlink.h
===================================================================
--- net-2.6.20.orig/include/net/genetlink.h	2006-11-14 12:23:56.000000000 +0100
+++ net-2.6.20/include/net/genetlink.h	2006-11-14 12:46:16.000000000 +0100
@@ -150,6 +150,16 @@
 }
 
 /**
+ * genlmsg_reply - reply to a request
+ * @skb: netlink message to be sent back
+ * @info: receiver information
+ */
+static inline int genlmsg_reply(struct sk_buff *skb, struct genl_info *info)
+{
+	return genlmsg_unicast(skb, info->snd_pid);
+}
+
+/**
  * gennlmsg_data - head of message payload
  * @gnlh: genetlink messsage header
  */
Index: net-2.6.20/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_cipso_v4.c	2006-11-14 12:23:43.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_cipso_v4.c	2006-11-14 12:46:02.000000000 +0100
@@ -568,7 +568,7 @@
 
 	genlmsg_end(ans_skb, data);
 
-	ret_val = genlmsg_unicast(ans_skb, info->snd_pid);
+	ret_val = genlmsg_reply(ans_skb, info);
 	if (ret_val != 0)
 		goto list_failure;
 
Index: net-2.6.20/net/netlink/genetlink.c
===================================================================
--- net-2.6.20.orig/net/netlink/genetlink.c	2006-11-14 12:23:43.000000000 +0100
+++ net-2.6.20/net/netlink/genetlink.c	2006-11-14 12:46:02.000000000 +0100
@@ -529,7 +529,7 @@
 		goto errout;
 	}
 
-	err = genlmsg_unicast(msg, info->snd_pid);
+	err = genlmsg_reply(msg, info);
 errout:
 	return err;
 }
Index: net-2.6.20/net/netlabel/netlabel_mgmt.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_mgmt.c	2006-11-14 12:23:43.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_mgmt.c	2006-11-14 12:46:02.000000000 +0100
@@ -390,7 +390,7 @@
 
 	genlmsg_end(ans_skb, data);
 
-	ret_val = genlmsg_unicast(ans_skb, info->snd_pid);
+	ret_val = genlmsg_reply(ans_skb, info);
 	if (ret_val != 0)
 		goto listdef_failure;
 	return 0;
@@ -512,7 +512,7 @@
 
 	genlmsg_end(ans_skb, data);
 
-	ret_val = genlmsg_unicast(ans_skb, info->snd_pid);
+	ret_val = genlmsg_reply(ans_skb, info);
 	if (ret_val != 0)
 		goto version_failure;
 	return 0;
Index: net-2.6.20/net/netlabel/netlabel_unlabeled.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_unlabeled.c	2006-11-14 12:23:43.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_unlabeled.c	2006-11-14 12:46:02.000000000 +0100
@@ -160,7 +160,7 @@
 
 	genlmsg_end(ans_skb, data);
 
-	ret_val = genlmsg_unicast(ans_skb, info->snd_pid);
+	ret_val = genlmsg_reply(ans_skb, info);
 	if (ret_val != 0)
 		goto list_failure;
 	return 0;

--

