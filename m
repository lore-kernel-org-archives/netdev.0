From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/5] net: fix message priorities
Date: Fri, 29 Aug 2014 00:09:19 -0700
Message-ID: <20140829071027.960922048@networkplumber.org>
References: <20140829070918.508987897@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:49061 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaH2HKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 03:10:30 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so5863094pad.27
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 00:10:29 -0700 (PDT)
Content-Disposition: inline; filename=net-dbg-msg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using obsolete socket type should be notice not info level.
Registering is normal and should only be debug level.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/socket.c	2014-08-12 13:07:42.000000000 -0700
+++ b/net/socket.c	2014-08-23 10:44:47.118408989 -0700
@@ -1276,8 +1276,8 @@ int __sock_create(struct net *net, int f
 		static int warned;
 		if (!warned) {
 			warned = 1;
-			pr_info("%s uses obsolete (PF_INET,SOCK_PACKET)\n",
-				current->comm);
+			pr_notice("%s uses obsolete (PF_INET,SOCK_PACKET)\n",
+				  current->comm);
 		}
 		family = PF_PACKET;
 	}
@@ -2624,7 +2624,7 @@ int sock_register(const struct net_proto
 	}
 	spin_unlock(&net_family_lock);
 
-	pr_info("NET: Registered protocol family %d\n", ops->family);
+	pr_debug("NET: Registered protocol family %d\n", ops->family);
 	return err;
 }
 EXPORT_SYMBOL(sock_register);
@@ -2652,7 +2652,7 @@ void sock_unregister(int family)
 
 	synchronize_rcu();
 
-	pr_info("NET: Unregistered protocol family %d\n", family);
+	pr_debug("NET: Unregistered protocol family %d\n", family);
 }
 EXPORT_SYMBOL(sock_unregister);
 
