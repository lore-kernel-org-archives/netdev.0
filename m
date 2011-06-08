From: Jiajun Wu <b06378@freescale.com>
Subject: [PATCH] gianfar:localized filer table
Date: Wed, 8 Jun 2011 15:46:51 +0800
Message-ID: <1307519211-3540-1-git-send-email-b06378@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, Jiajun Wu <b06378@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:5700
	"EHLO CH1EHSOBE013.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752429Ab1FHIjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 04:39:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each eTSEC device should own localized filer table.

Signed-off-by: Jiajun Wu <b06378@freescale.com>
---
 drivers/net/gianfar.c         |   29 ++++++++----------
 drivers/net/gianfar.h         |    8 +++--
 drivers/net/gianfar_ethtool.c |   64 +++++++++++++++++++++--------------------
 3 files changed, 51 insertions(+), 50 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ff60b23..2dfcc80 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -10,7 +10,7 @@
  * Maintainer: Kumar Gala
  * Modifier: Sandeep Gopalpet <sandeep.kumar@freescale.com>
  *
- * Copyright 2002-2009 Freescale Semiconductor, Inc.
+ * Copyright 2002-2009, 2011 Freescale Semiconductor, Inc.
  * Copyright 2007 MontaVista Software, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
@@ -476,9 +476,6 @@ static const struct net_device_ops gfar_netdev_ops = {
 #endif
 };
 
-unsigned int ftp_rqfpr[MAX_FILER_IDX + 1];
-unsigned int ftp_rqfcr[MAX_FILER_IDX + 1];
-
 void lock_rx_qs(struct gfar_private *priv)
 {
 	int i = 0x0;
@@ -868,28 +865,28 @@ static u32 cluster_entry_per_class(struct gfar_private *priv, u32 rqfar,
 
 	rqfar--;
 	rqfcr = RQFCR_CLE | RQFCR_PID_MASK | RQFCR_CMP_EXACT;
-	ftp_rqfpr[rqfar] = rqfpr;
-	ftp_rqfcr[rqfar] = rqfcr;
+	priv->ftp_rqfpr[rqfar] = rqfpr;
+	priv->ftp_rqfcr[rqfar] = rqfcr;
 	gfar_write_filer(priv, rqfar, rqfcr, rqfpr);
 
 	rqfar--;
 	rqfcr = RQFCR_CMP_NOMATCH;
-	ftp_rqfpr[rqfar] = rqfpr;
-	ftp_rqfcr[rqfar] = rqfcr;
+	priv->ftp_rqfpr[rqfar] = rqfpr;
+	priv->ftp_rqfcr[rqfar] = rqfcr;
 	gfar_write_filer(priv, rqfar, rqfcr, rqfpr);
 
 	rqfar--;
 	rqfcr = RQFCR_CMP_EXACT | RQFCR_PID_PARSE | RQFCR_CLE | RQFCR_AND;
 	rqfpr = class;
-	ftp_rqfcr[rqfar] = rqfcr;
-	ftp_rqfpr[rqfar] = rqfpr;
+	priv->ftp_rqfcr[rqfar] = rqfcr;
+	priv->ftp_rqfpr[rqfar] = rqfpr;
 	gfar_write_filer(priv, rqfar, rqfcr, rqfpr);
 
 	rqfar--;
 	rqfcr = RQFCR_CMP_EXACT | RQFCR_PID_MASK | RQFCR_AND;
 	rqfpr = class;
-	ftp_rqfcr[rqfar] = rqfcr;
-	ftp_rqfpr[rqfar] = rqfpr;
+	priv->ftp_rqfcr[rqfar] = rqfcr;
+	priv->ftp_rqfpr[rqfar] = rqfpr;
 	gfar_write_filer(priv, rqfar, rqfcr, rqfpr);
 
 	return rqfar;
@@ -904,8 +901,8 @@ static void gfar_init_filer_table(struct gfar_private *priv)
 
 	/* Default rule */
 	rqfcr = RQFCR_CMP_MATCH;
-	ftp_rqfcr[rqfar] = rqfcr;
-	ftp_rqfpr[rqfar] = rqfpr;
+	priv->ftp_rqfcr[rqfar] = rqfcr;
+	priv->ftp_rqfpr[rqfar] = rqfpr;
 	gfar_write_filer(priv, rqfar, rqfcr, rqfpr);
 
 	rqfar = cluster_entry_per_class(priv, rqfar, RQFPR_IPV6);
@@ -921,8 +918,8 @@ static void gfar_init_filer_table(struct gfar_private *priv)
 	/* Rest are masked rules */
 	rqfcr = RQFCR_CMP_NOMATCH;
 	for (i = 0; i < rqfar; i++) {
-		ftp_rqfcr[i] = rqfcr;
-		ftp_rqfpr[i] = rqfpr;
+		priv->ftp_rqfcr[i] = rqfcr;
+		priv->ftp_rqfpr[i] = rqfpr;
 		gfar_write_filer(priv, i, rqfcr, rqfpr);
 	}
 }
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index fc86f51..ba36dc7 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -9,7 +9,7 @@
  * Maintainer: Kumar Gala
  * Modifier: Sandeep Gopalpet <sandeep.kumar@freescale.com>
  *
- * Copyright 2002-2009 Freescale Semiconductor, Inc.
+ * Copyright 2002-2009, 2011 Freescale Semiconductor, Inc.
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -1107,10 +1107,12 @@ struct gfar_private {
 	/* HW time stamping enabled flag */
 	int hwts_rx_en;
 	int hwts_tx_en;
+
+	/*Filer table*/
+	unsigned int ftp_rqfpr[MAX_FILER_IDX + 1];
+	unsigned int ftp_rqfcr[MAX_FILER_IDX + 1];
 };
 
-extern unsigned int ftp_rqfpr[MAX_FILER_IDX + 1];
-extern unsigned int ftp_rqfcr[MAX_FILER_IDX + 1];
 
 static inline int gfar_has_errata(struct gfar_private *priv,
 				  enum gfar_errata err)
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 493d743..239e333 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -9,7 +9,7 @@
  *  Maintainer: Kumar Gala
  *  Modifier: Sandeep Gopalpet <sandeep.kumar@freescale.com>
  *
- *  Copyright 2003-2006, 2008-2009 Freescale Semiconductor, Inc.
+ *  Copyright 2003-2006, 2008-2009, 2011 Freescale Semiconductor, Inc.
  *
  *  This software may be used and distributed according to
  *  the terms of the GNU Public License, Version 2, incorporated herein
@@ -609,15 +609,15 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 	if (ethflow & RXH_L2DA) {
 		fcr = RQFCR_PID_DAH |RQFCR_CMP_NOMATCH |
 			RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
-		ftp_rqfpr[priv->cur_filer_idx] = fpr;
-		ftp_rqfcr[priv->cur_filer_idx] = fcr;
+		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
+		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 
 		fcr = RQFCR_PID_DAL | RQFCR_AND | RQFCR_CMP_NOMATCH |
 				RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
-		ftp_rqfpr[priv->cur_filer_idx] = fpr;
-		ftp_rqfcr[priv->cur_filer_idx] = fcr;
+		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
+		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 	}
@@ -626,16 +626,16 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 		fcr = RQFCR_PID_VID | RQFCR_CMP_NOMATCH | RQFCR_HASH |
 				RQFCR_AND | RQFCR_HASHTBL_0;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
-		ftp_rqfpr[priv->cur_filer_idx] = fpr;
-		ftp_rqfcr[priv->cur_filer_idx] = fcr;
+		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
+		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 	}
 
 	if (ethflow & RXH_IP_SRC) {
 		fcr = RQFCR_PID_SIA | RQFCR_CMP_NOMATCH | RQFCR_HASH |
 			RQFCR_AND | RQFCR_HASHTBL_0;
-		ftp_rqfpr[priv->cur_filer_idx] = fpr;
-		ftp_rqfcr[priv->cur_filer_idx] = fcr;
+		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
+		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 	}
@@ -643,8 +643,8 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 	if (ethflow & (RXH_IP_DST)) {
 		fcr = RQFCR_PID_DIA | RQFCR_CMP_NOMATCH | RQFCR_HASH |
 			RQFCR_AND | RQFCR_HASHTBL_0;
-		ftp_rqfpr[priv->cur_filer_idx] = fpr;
-		ftp_rqfcr[priv->cur_filer_idx] = fcr;
+		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
+		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 	}
@@ -652,8 +652,8 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 	if (ethflow & RXH_L3_PROTO) {
 		fcr = RQFCR_PID_L4P | RQFCR_CMP_NOMATCH | RQFCR_HASH |
 			RQFCR_AND | RQFCR_HASHTBL_0;
-		ftp_rqfpr[priv->cur_filer_idx] = fpr;
-		ftp_rqfcr[priv->cur_filer_idx] = fcr;
+		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
+		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 	}
@@ -661,8 +661,8 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 	if (ethflow & RXH_L4_B_0_1) {
 		fcr = RQFCR_PID_SPT | RQFCR_CMP_NOMATCH | RQFCR_HASH |
 			RQFCR_AND | RQFCR_HASHTBL_0;
-		ftp_rqfpr[priv->cur_filer_idx] = fpr;
-		ftp_rqfcr[priv->cur_filer_idx] = fcr;
+		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
+		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 	}
@@ -670,8 +670,8 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 	if (ethflow & RXH_L4_B_2_3) {
 		fcr = RQFCR_PID_DPT | RQFCR_CMP_NOMATCH | RQFCR_HASH |
 			RQFCR_AND | RQFCR_HASHTBL_0;
-		ftp_rqfpr[priv->cur_filer_idx] = fpr;
-		ftp_rqfcr[priv->cur_filer_idx] = fcr;
+		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
+		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 	}
@@ -705,12 +705,12 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 	}
 
 	for (i = 0; i < MAX_FILER_IDX + 1; i++) {
-		local_rqfpr[j] = ftp_rqfpr[i];
-		local_rqfcr[j] = ftp_rqfcr[i];
+		local_rqfpr[j] = priv->ftp_rqfpr[i];
+		local_rqfcr[j] = priv->ftp_rqfcr[i];
 		j--;
-		if ((ftp_rqfcr[i] == (RQFCR_PID_PARSE |
+		if ((priv->ftp_rqfcr[i] == (RQFCR_PID_PARSE |
 			RQFCR_CLE |RQFCR_AND)) &&
-			(ftp_rqfpr[i] == cmp_rqfpr))
+			(priv->ftp_rqfpr[i] == cmp_rqfpr))
 			break;
 	}
 
@@ -724,20 +724,22 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 	 * if it was already programmed, we need to overwrite these rules
 	 */
 	for (l = i+1; l < MAX_FILER_IDX; l++) {
-		if ((ftp_rqfcr[l] & RQFCR_CLE) &&
-			!(ftp_rqfcr[l] & RQFCR_AND)) {
-			ftp_rqfcr[l] = RQFCR_CLE | RQFCR_CMP_EXACT |
+		if ((priv->ftp_rqfcr[l] & RQFCR_CLE) &&
+			!(priv->ftp_rqfcr[l] & RQFCR_AND)) {
+			priv->ftp_rqfcr[l] = RQFCR_CLE | RQFCR_CMP_EXACT |
 				RQFCR_HASHTBL_0 | RQFCR_PID_MASK;
-			ftp_rqfpr[l] = FPR_FILER_MASK;
-			gfar_write_filer(priv, l, ftp_rqfcr[l], ftp_rqfpr[l]);
+			priv->ftp_rqfpr[l] = FPR_FILER_MASK;
+			gfar_write_filer(priv, l, priv->ftp_rqfcr[l],
+				priv->ftp_rqfpr[l]);
 			break;
 		}
 
-		if (!(ftp_rqfcr[l] & RQFCR_CLE) && (ftp_rqfcr[l] & RQFCR_AND))
+		if (!(priv->ftp_rqfcr[l] & RQFCR_CLE) &&
+			(priv->ftp_rqfcr[l] & RQFCR_AND))
 			continue;
 		else {
-			local_rqfpr[j] = ftp_rqfpr[l];
-			local_rqfcr[j] = ftp_rqfcr[l];
+			local_rqfpr[j] = priv->ftp_rqfpr[l];
+			local_rqfcr[j] = priv->ftp_rqfcr[l];
 			j--;
 		}
 	}
@@ -750,8 +752,8 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 
 	/* Write back the popped out rules again */
 	for (k = j+1; k < MAX_FILER_IDX; k++) {
-		ftp_rqfpr[priv->cur_filer_idx] = local_rqfpr[k];
-		ftp_rqfcr[priv->cur_filer_idx] = local_rqfcr[k];
+		priv->ftp_rqfpr[priv->cur_filer_idx] = local_rqfpr[k];
+		priv->ftp_rqfcr[priv->cur_filer_idx] = local_rqfcr[k];
 		gfar_write_filer(priv, priv->cur_filer_idx,
 				local_rqfcr[k], local_rqfpr[k]);
 		if (!priv->cur_filer_idx)
-- 
1.5.6.5


