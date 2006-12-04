From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/1] myri10ge: write as 2 32-byte blocks in myri10ge_submit_8rx
Date: Mon, 04 Dec 2006 11:33:31 +0100
Message-ID: <4573F97B.90707@myri.com>
References: <4573F8ED.3050304@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:35721 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1758542AbWLDKeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 05:34:20 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4573F8ED.3050304@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the myri10ge_submit_8rx() routine, write the 64 byte request block as
2 32-byte blocks so that it is handled by the hardware pio write handler
if write-combining is enabled.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6.19/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.19.orig/drivers/net/myri10ge/myri10ge.c	2006-11-29 22:57:37.000000000 +0100
+++ linux-2.6.19/drivers/net/myri10ge/myri10ge.c	2006-12-04 11:22:48.000000000 +0100
@@ -790,7 +790,9 @@
 
 	low = src->addr_low;
 	src->addr_low = DMA_32BIT_MASK;
-	myri10ge_pio_copy(dst, src, 8 * sizeof(*src));
+	myri10ge_pio_copy(dst, src, 4 * sizeof(*src));
+	mb();
+	myri10ge_pio_copy(dst + 4, src + 4, 4 * sizeof(*src));
 	mb();
 	src->addr_low = low;
 	__raw_writel(low, &dst->addr_low);


