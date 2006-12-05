From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/1] myri10ge: write as 2 32-byte blocks in myri10ge_submit_8rx
Date: Tue, 05 Dec 2006 17:26:27 +0100
Message-ID: <45759DB3.3020905@myri.com>
References: <4573F8ED.3050304@myri.com> <4573F97B.90707@myri.com> <4574B0F9.9070409@garzik.org> <45759016.3050207@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:57149 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S968427AbWLEQ0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 11:26:46 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45759016.3050207@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the myri10ge_submit_8rx() routine, write the 64 byte request block as
2 32-byte blocks so that it is handled by the hardware pio write handler
if write-combining is enabled.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: netdev-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- netdev-2.6.orig/drivers/net/myri10ge/myri10ge.c	2006-12-05 16:29:14.000000000 +0100
+++ netdev-2.6/drivers/net/myri10ge/myri10ge.c	2006-12-05 16:30:08.000000000 +0100
@@ -795,7 +795,9 @@
 
 	low = src->addr_low;
 	src->addr_low = htonl(DMA_32BIT_MASK);
-	myri10ge_pio_copy(dst, src, 8 * sizeof(*src));
+	myri10ge_pio_copy(dst, src, 4 * sizeof(*src));
+	mb();
+	myri10ge_pio_copy(dst + 4, src + 4, 4 * sizeof(*src));
 	mb();
 	src->addr_low = low;
 	put_be32(low, &dst->addr_low);


