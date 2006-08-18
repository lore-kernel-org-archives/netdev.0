From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] skge: fix swapped kcalloc() arguments
Date: Fri, 18 Aug 2006 23:54:52 +0200
Message-ID: <200608182354.52537.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:45257
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751501AbWHRVzh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 17:55:37 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Stephen,

Please push the following fix upstream.

--

/**
 * kcalloc - allocate memory for an array. The memory is set to zero.
 * @n: number of elements.
 * @size: element size.
 * @flags: the type of memory to allocate.
 */

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: linux-2.6/drivers/net/skge.c
===================================================================
--- linux-2.6.orig/drivers/net/skge.c	2006-08-02 22:57:23.000000000 +0200
+++ linux-2.6/drivers/net/skge.c	2006-08-18 23:52:43.000000000 +0200
@@ -731,7 +731,7 @@
 	struct skge_element *e;
 	int i;
 
-	ring->start = kcalloc(sizeof(*e), ring->count, GFP_KERNEL);
+	ring->start = kcalloc(ring->count, sizeof(*e), GFP_KERNEL);
 	if (!ring->start)
 		return -ENOMEM;
 

-- 
Greetings Michael.
