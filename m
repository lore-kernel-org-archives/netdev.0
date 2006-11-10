From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv6] rules: Remove bogus tos validation check
Date: Fri, 10 Nov 2006 13:28:38 +0100
Message-ID: <20061110122838.GI8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:63203 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1946098AbWKJM2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 07:28:17 -0500
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Noticed by Al Viro:
     (frh->tos & ~IPV6_FLOWINFO_MASK))
where IPV6_FLOWINFO_MASK is htonl(0xfffffff) and frh->tos
is u8, which makes no sense here...

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv6/fib6_rules.c	2006-11-10 13:17:40.000000000 +0100
+++ net-2.6.20/net/ipv6/fib6_rules.c	2006-11-10 13:18:16.000000000 +0100
@@ -142,8 +142,7 @@
 	int err = -EINVAL;
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
 
-	if (frh->src_len > 128 || frh->dst_len > 128 ||
-	    (frh->tos & ~IPV6_FLOWINFO_MASK))
+	if (frh->src_len > 128 || frh->dst_len > 128)
 		goto errout;
 
 	if (rule->action == FR_ACT_TO_TBL) {
