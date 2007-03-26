From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [NET] fib_rules: Add no-operation action
Date: Tue, 27 Mar 2007 01:54:53 +0200
Message-ID: <20070326235713.748511324@lsx.localdomain>
References: <20070326235450.756924134@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52610 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933813AbXCZX6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 19:58:44 -0400
Content-Disposition: inline; filename=rule_nop
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of nop rules simplifies the usage of goto rules
and adds more flexibility as they allow targets to remain
while the actual content of the branches can change easly.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/linux/fib_rules.h
===================================================================
--- net-2.6.22.orig/include/linux/fib_rules.h	2007-03-27 01:45:56.000000000 +0200
+++ net-2.6.22/include/linux/fib_rules.h	2007-03-27 01:46:33.000000000 +0200
@@ -54,7 +54,7 @@ enum
 	FR_ACT_UNSPEC,
 	FR_ACT_TO_TBL,		/* Pass to fixed table */
 	FR_ACT_GOTO,		/* Jump to another rule */
-	FR_ACT_RES2,
+	FR_ACT_NOP,		/* No operation */
 	FR_ACT_RES3,
 	FR_ACT_RES4,
 	FR_ACT_BLACKHOLE,	/* Drop without notification */
Index: net-2.6.22/net/core/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/core/fib_rules.c	2007-03-27 01:46:22.000000000 +0200
+++ net-2.6.22/net/core/fib_rules.c	2007-03-27 01:46:33.000000000 +0200
@@ -146,7 +146,9 @@ jumped:
 				rule = target;
 				goto jumped;
 			}
-		} else
+		} else if (rule->action == FR_ACT_NOP)
+			continue;
+		else
 			err = ops->action(rule, fl, flags, arg);
 
 		if (err != -EAGAIN) {

--

