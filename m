From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: long/ulong iproute-git fix
Date: Wed, 30 Jul 2008 17:34:07 +0300
Message-ID: <200807301734.07598.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_fvHkIrCYhq1ypsq"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:59519 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbYG3Oed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 10:34:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_fvHkIrCYhq1ypsq
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch fixes bug in Metadata ematch attributes parser

strtoul on error return ULONG_MAX, not LONG_MAX

Patch attached as file

--Boundary-00=_fvHkIrCYhq1ypsq
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iproute2-30jul2008-ulong.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="iproute2-30jul2008-ulong.patch"

diff -Naur iproute2/tc/em_meta.c iproute2-patched/tc/em_meta.c
--- iproute2/tc/em_meta.c	2008-07-30 17:29:57.000000000 +0300
+++ iproute2-patched/tc/em_meta.c	2008-07-30 17:29:15.000000000 +0300
@@ -262,7 +262,7 @@
 	}
 
 	num = bstrtoul(arg);
-	if (num != LONG_MAX) {
+	if (num != ULONG_MAX) {
 		obj->kind = TCF_META_TYPE_INT << 12;
 		obj->kind |= TCF_META_ID_VALUE;
 		*dst = (unsigned long) num;
@@ -320,7 +320,7 @@
 			a = bstr_next(a);
 
 			shift = bstrtoul(a);
-			if (shift == LONG_MAX) {
+			if (shift == ULONG_MAX) {
 				PARSE_ERR(a, "meta: invalid shift, must " \
 				    "be numeric");
 				return PARSE_FAILURE;
@@ -338,7 +338,7 @@
 			a = bstr_next(a);
 
 			mask = bstrtoul(a);
-			if (mask == LONG_MAX) {
+			if (mask == ULONG_MAX) {
 				PARSE_ERR(a, "meta: invalid mask, must be " \
 				    "numeric");
 				return PARSE_FAILURE;

--Boundary-00=_fvHkIrCYhq1ypsq--
