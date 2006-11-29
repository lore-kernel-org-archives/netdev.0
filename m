From: Thomas Graf <tgraf@suug.ch>
Subject: [DECNet] fib: Fix out of bound access of fib_props[]
Date: Wed, 29 Nov 2006 14:55:46 +0100
Message-ID: <20061129135546.GA8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46741 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S967172AbWK2NzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 08:55:25 -0500
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a typo which caused fib_props[] to have the wrong size
and makes sure the value used to index the array which is
provided by userspace via netlink is checked to avoid out of
bound access.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/decnet/dn_fib.c
===================================================================
--- net-2.6.orig/net/decnet/dn_fib.c	2006-11-29 13:35:51.000000000 +0100
+++ net-2.6/net/decnet/dn_fib.c	2006-11-29 13:36:17.000000000 +0100
@@ -63,7 +63,7 @@
 {
 	int error;
 	u8 scope;
-} dn_fib_props[RTA_MAX+1] = {
+} dn_fib_props[RTN_MAX+1] = {
 	[RTN_UNSPEC] =      { .error = 0,       .scope = RT_SCOPE_NOWHERE },
 	[RTN_UNICAST] =     { .error = 0,       .scope = RT_SCOPE_UNIVERSE },
 	[RTN_LOCAL] =       { .error = 0,       .scope = RT_SCOPE_HOST },
@@ -276,6 +276,9 @@
 	struct dn_fib_info *ofi;
 	int nhs = 1;
 
+	if (r->rtm_type > RTN_MAX)
+		goto err_inval;
+
 	if (dn_fib_props[r->rtm_type].scope > r->rtm_scope)
 		goto err_inval;
 
