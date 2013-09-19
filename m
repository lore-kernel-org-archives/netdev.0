From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] declance: Remove `incompatible pointer type' warnings
Date: Fri, 20 Sep 2013 00:49:44 +0100 (BST)
Message-ID: <alpine.LFD.2.03.1309200008060.5967@linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:49558 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab3ISXtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 19:49:46 -0400
Received: from localhost.localdomain ([127.0.0.1]:57364 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6823977Ab3ISXtopmdg0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 01:49:44 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Revert damage caused by 43d620c82985b19008d87a437b4cf83f356264f7:

.../declance.c: In function 'cp_to_buf':
.../declance.c:347: warning: assignment from incompatible pointer type
.../declance.c:348: warning: assignment from incompatible pointer type
.../declance.c: In function 'cp_from_buf':
.../declance.c:406: warning: assignment from incompatible pointer type
.../declance.c:407: warning: assignment from incompatible pointer type

Also add a `const' qualifier where applicable and adjust formatting.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
linux-declance-cast-fix.patch
Index: linux-mips-3.12.0-rc1-20130917-4maxp/drivers/net/ethernet/amd/declance.c
===================================================================
--- linux-mips-3.12.0-rc1-20130917-4maxp.orig/drivers/net/ethernet/amd/declance.c
+++ linux-mips-3.12.0-rc1-20130917-4maxp/drivers/net/ethernet/amd/declance.c
@@ -344,8 +344,8 @@ static void cp_to_buf(const int type, vo
 		}
 
 		clen = len & 1;
-		rtp = tp;
-		rfp = fp;
+		rtp = (unsigned char *)tp;
+		rfp = (const unsigned char *)fp;
 		while (clen--) {
 			*rtp++ = *rfp++;
 		}
@@ -372,8 +372,8 @@ static void cp_to_buf(const int type, vo
 		 * do the rest, if any.
 		 */
 		clen = len & 15;
-		rtp = (unsigned char *) tp;
-		rfp = (unsigned char *) fp;
+		rtp = (unsigned char *)tp;
+		rfp = (const unsigned char *)fp;
 		while (clen--) {
 			*rtp++ = *rfp++;
 		}
@@ -403,8 +403,8 @@ static void cp_from_buf(const int type, 
 
 		clen = len & 1;
 
-		rtp = tp;
-		rfp = fp;
+		rtp = (unsigned char *)tp;
+		rfp = (const unsigned char *)fp;
 
 		while (clen--) {
 			*rtp++ = *rfp++;
@@ -433,8 +433,8 @@ static void cp_from_buf(const int type, 
 		 * do the rest, if any.
 		 */
 		clen = len & 15;
-		rtp = (unsigned char *) tp;
-		rfp = (unsigned char *) fp;
+		rtp = (unsigned char *)tp;
+		rfp = (const unsigned char *)fp;
 		while (clen--) {
 			*rtp++ = *rfp++;
 		}
