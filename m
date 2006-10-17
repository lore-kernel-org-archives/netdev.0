From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv4] fib: Remove unused fib_config members
Date: Tue, 17 Oct 2006 16:11:14 +0200
Message-ID: <20061017141114.GP12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33000 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751083AbWJQOKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 10:10:53 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/include/net/ip_fib.h
===================================================================
--- net-2.6.orig/include/net/ip_fib.h	2006-10-17 14:35:00.000000000 +0200
+++ net-2.6/include/net/ip_fib.h	2006-10-17 14:36:16.000000000 +0200
@@ -21,17 +21,14 @@
 #include <net/fib_rules.h>
 
 struct fib_config {
-	u8			fc_family;
 	u8			fc_dst_len;
-	u8			fc_src_len;
 	u8			fc_tos;
 	u8			fc_protocol;
 	u8			fc_scope;
 	u8			fc_type;
-	/* 1 byte unused */
+	/* 3 bytes unused */
 	u32			fc_table;
 	__be32			fc_dst;
-	__be32			fc_src;
 	__be32			fc_gw;
 	int			fc_oif;
 	u32			fc_flags;
Index: net-2.6/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.orig/net/ipv4/fib_frontend.c	2006-10-17 14:35:00.000000000 +0200
+++ net-2.6/net/ipv4/fib_frontend.c	2006-10-17 14:36:16.000000000 +0200
@@ -482,9 +482,7 @@
 	memset(cfg, 0, sizeof(*cfg));
 
 	rtm = nlmsg_data(nlh);
-	cfg->fc_family = rtm->rtm_family;
 	cfg->fc_dst_len = rtm->rtm_dst_len;
-	cfg->fc_src_len = rtm->rtm_src_len;
 	cfg->fc_tos = rtm->rtm_tos;
 	cfg->fc_table = rtm->rtm_table;
 	cfg->fc_protocol = rtm->rtm_protocol;
@@ -501,9 +499,6 @@
 		case RTA_DST:
 			cfg->fc_dst = nla_get_be32(attr);
 			break;
-		case RTA_SRC:
-			cfg->fc_src = nla_get_be32(attr);
-			break;
 		case RTA_OIF:
 			cfg->fc_oif = nla_get_u32(attr);
 			break;
