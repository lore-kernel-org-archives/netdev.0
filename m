From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH] spidernet: Replace literal with const
Date: Thu, 14 Jun 2007 18:12:23 -0500
Message-ID: <20070614231223.GZ4397@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com> <20070611182650.GD13741@austin.ibm.com> <46704F90.7050508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:38431 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753698AbXFNXMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 19:12:32 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5ENCWoT006179
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 19:12:32 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5ENCVDg217746
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 17:12:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5ENCVGT014267
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 17:12:31 -0600
Content-Disposition: inline
In-Reply-To: <46704F90.7050508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replace literal with const; add bit definitions.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----

On Wed, Jun 13, 2007 at 04:12:00PM -0400, Jeff Garzik wrote:
> A follow-up patch needs to remove the above magic numbers (==numeric 
> constants), replacing them with named constants

Here it is. Lightly stres-tested (about 1/2 hour), as this patch
tests some additonal bits.

 drivers/net/spider_net.c |    2 +-
 drivers/net/spider_net.h |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 15:39:03.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-14 17:23:32.000000000 -0500
@@ -1235,7 +1235,7 @@ spider_net_decode_one_descr(struct spide
 		goto bad_desc;
 	}
 
-	if (hwdescr->dmac_cmd_status & 0xfcf4) {
+	if (hwdescr->dmac_cmd_status & SPIDER_NET_DESCR_BAD_STATUS) {
 		dev_err(&card->netdev->dev, "bad status, cmd_status=x%08x\n",
 			       hwdescr->dmac_cmd_status);
 		pr_err("buf_addr=x%08x\n", hw_buf_addr);
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-11 15:39:03.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-14 17:34:56.000000000 -0500
@@ -359,6 +359,18 @@ enum spider_net_int2_status {
 #define SPIDER_NET_DMAC_UDP			0x00030000
 #define SPIDER_NET_TXDCEST			0x08000000
 
+#define SPIDER_NET_DESCR_RXFDIS        0x00000001
+#define SPIDER_NET_DESCR_RXDCEIS       0x00000002
+#define SPIDER_NET_DESCR_RXDEN0IS      0x00000004
+#define SPIDER_NET_DESCR_RXINVDIS      0x00000008
+#define SPIDER_NET_DESCR_RXRERRIS      0x00000010
+#define SPIDER_NET_DESCR_RXFDCIMS      0x00000100
+#define SPIDER_NET_DESCR_RXDCEIMS      0x00000200
+#define SPIDER_NET_DESCR_RXDEN0IMS     0x00000400
+#define SPIDER_NET_DESCR_RXINVDIMS     0x00000800
+#define SPIDER_NET_DESCR_RXRERRMIS     0x00001000
+#define SPIDER_NET_DESCR_UNUSED        0x077fe0e0
+
 #define SPIDER_NET_DESCR_IND_PROC_MASK		0xF0000000
 #define SPIDER_NET_DESCR_COMPLETE		0x00000000 /* used in rx and tx */
 #define SPIDER_NET_DESCR_RESPONSE_ERROR		0x10000000 /* used in rx and tx */
@@ -369,6 +381,13 @@ enum spider_net_int2_status {
 #define SPIDER_NET_DESCR_NOT_IN_USE		0xF0000000
 #define SPIDER_NET_DESCR_TXDESFLG		0x00800000
 
+#define SPIDER_NET_DESCR_BAD_STATUS   (SPIDER_NET_DESCR_RXDEN0IS | \
+                                       SPIDER_NET_DESCR_RXRERRIS | \
+                                       SPIDER_NET_DESCR_RXDEN0IMS | \
+                                       SPIDER_NET_DESCR_RXINVDIMS | \
+                                       SPIDER_NET_DESCR_RXRERRMIS | \
+                                       SPIDER_NET_DESCR_UNUSED)
+
 /* Descriptor, as defined by the hardware */
 struct spider_net_hw_descr {
 	u32 buf_addr;
