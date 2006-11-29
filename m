From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv4] fib: Fix out of bound access of fib_props[]
Date: Wed, 29 Nov 2006 14:55:11 +0100
Message-ID: <20061129135511.GZ8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44693 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S966972AbWK2Nyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 08:54:51 -0500
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a typo which caused fib_props[] to have the wrong size
and makes sure the value used to index the array which is
provided by userspace via netlink is checked to avoid out of
bound access.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.orig/net/ipv4/fib_semantics.c	2006-11-29 13:33:05.000000000 +0100
+++ net-2.6/net/ipv4/fib_semantics.c	2006-11-29 13:36:13.000000000 +0100
@@ -89,7 +89,7 @@
 {
 	int	error;
 	u8	scope;
-} fib_props[RTA_MAX + 1] = {
+} fib_props[RTN_MAX + 1] = {
         {
 		.error	= 0,
 		.scope	= RT_SCOPE_NOWHERE,
@@ -658,6 +658,9 @@
 	struct fib_info *ofi;
 	int nhs = 1;
 
+	if (cfg->fc_type > RTN_MAX)
+		goto err_inval;
+
 	/* Fast check to catch the most weird cases */
 	if (fib_props[cfg->fc_type].scope > cfg->fc_scope)
 		goto err_inval;
