From: Surya Prabhakar N <surya.prabhakar@wipro.com>
Subject: [KJ] replacing kmalloc with kzalloc in drivers/net/sb1250-mac.c
Date: Mon, 13 Aug 2007 15:28:43 +0530
Message-ID: <1186999123.29518.18.camel@bluegenie>
Reply-To: surya.prabhakar@wipro.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:42830 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934323AbXHMJ7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 05:59:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
   Replacing kmalloc with kzalloc and cleaning up memset in 
drivers/net/sb1250-mac.c


Signed-off-by: Surya Prabhakar <surya.prabhakar@wipro.com>
---

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index e7fdcf1..2dca5a7 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -760,7 +760,7 @@ static void sbdma_initctx(sbmacdma_t *d,
 
 	d->sbdma_dscrtable_unaligned =
 	d->sbdma_dscrtable = (sbdmadscr_t *)
-		kmalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
+		kzalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
 
 	/*
 	 * The descriptor table must be aligned to at least 16 bytes or the
@@ -769,8 +769,6 @@ static void sbdma_initctx(sbmacdma_t *d,
 	d->sbdma_dscrtable = (sbdmadscr_t *)
 		ALIGN((unsigned long)d->sbdma_dscrtable, sizeof(sbdmadscr_t));
 
-	memset(d->sbdma_dscrtable,0,d->sbdma_maxdescr*sizeof(sbdmadscr_t));
-
 	d->sbdma_dscrtable_end = d->sbdma_dscrtable + d->sbdma_maxdescr;
 
 	d->sbdma_dscrtable_phys = virt_to_phys(d->sbdma_dscrtable);
@@ -780,9 +778,7 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 */
 
 	d->sbdma_ctxtable = (struct sk_buff **)
-		kmalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
-
-	memset(d->sbdma_ctxtable,0,d->sbdma_maxdescr*sizeof(struct sk_buff *));
+		kzalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
 
 #ifdef CONFIG_SBMAC_COALESCE
 	/*

--
thanks
surya.
