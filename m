From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv4] route: Remove unused ifa_anycast field
Date: Mon, 26 May 2008 13:42:51 +0200
Message-ID: <20080526114251.GA20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57148 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754279AbYEZLma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 07:42:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The field was supposed to allow the creation of an anycast route by
assigning an anycast address to an address prefix. It was never
implemented so this field is unused and serves no purpose. Remove it.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/include/linux/inetdevice.h
===================================================================
--- net-2.6.orig/include/linux/inetdevice.h	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/include/linux/inetdevice.h	2008-05-26 13:32:24.000000000 +0200
@@ -117,7 +117,6 @@
 	__be32			ifa_address;
 	__be32			ifa_mask;
 	__be32			ifa_broadcast;
-	__be32			ifa_anycast;
 	unsigned char		ifa_scope;
 	unsigned char		ifa_flags;
 	unsigned char		ifa_prefixlen;
Index: net-2.6/net/ipv4/devinet.c
===================================================================
--- net-2.6.orig/net/ipv4/devinet.c	2008-05-26 13:25:15.000000000 +0200
+++ net-2.6/net/ipv4/devinet.c	2008-05-26 13:32:24.000000000 +0200
@@ -90,7 +90,6 @@
 	[IFA_LOCAL]     	= { .type = NLA_U32 },
 	[IFA_ADDRESS]   	= { .type = NLA_U32 },
 	[IFA_BROADCAST] 	= { .type = NLA_U32 },
-	[IFA_ANYCAST]   	= { .type = NLA_U32 },
 	[IFA_LABEL]     	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 };
 
@@ -536,9 +535,6 @@
 	if (tb[IFA_BROADCAST])
 		ifa->ifa_broadcast = nla_get_be32(tb[IFA_BROADCAST]);
 
-	if (tb[IFA_ANYCAST])
-		ifa->ifa_anycast = nla_get_be32(tb[IFA_ANYCAST]);
-
 	if (tb[IFA_LABEL])
 		nla_strlcpy(ifa->ifa_label, tb[IFA_LABEL], IFNAMSIZ);
 	else
@@ -745,7 +741,6 @@
 				break;
 			inet_del_ifa(in_dev, ifap, 0);
 			ifa->ifa_broadcast = 0;
-			ifa->ifa_anycast = 0;
 			ifa->ifa_scope = 0;
 		}
 
@@ -1113,7 +1108,6 @@
 	       + nla_total_size(4) /* IFA_ADDRESS */
 	       + nla_total_size(4) /* IFA_LOCAL */
 	       + nla_total_size(4) /* IFA_BROADCAST */
-	       + nla_total_size(4) /* IFA_ANYCAST */
 	       + nla_total_size(IFNAMSIZ); /* IFA_LABEL */
 }
 
@@ -1143,9 +1137,6 @@
 	if (ifa->ifa_broadcast)
 		NLA_PUT_BE32(skb, IFA_BROADCAST, ifa->ifa_broadcast);
 
-	if (ifa->ifa_anycast)
-		NLA_PUT_BE32(skb, IFA_ANYCAST, ifa->ifa_anycast);
-
 	if (ifa->ifa_label[0])
 		NLA_PUT_STRING(skb, IFA_LABEL, ifa->ifa_label);
 
