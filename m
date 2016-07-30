From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 05/10] drivers: net: xgene: Fix RSS indirection table fields
Date: Fri, 29 Jul 2016 17:33:58 -0700
Message-ID: <1469838843-19943-6-git-send-email-isubramanian@apm.com>
References: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>,
	Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34603 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549AbcG3Ad3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 20:33:29 -0400
Received: by mail-pf0-f178.google.com with SMTP id p64so37120574pfb.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 17:33:29 -0700 (PDT)
In-Reply-To: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes FPSel and NxtFPSel fields length to 5-bit value.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c | 17 ++++++++++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h | 10 +++++++---
 2 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
index 472c0fb..23d72af 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
@@ -32,12 +32,19 @@ static void xgene_cle_sband_to_hw(u8 frag, enum xgene_cle_prot_version ver,
 		SET_VAL(SB_HDRLEN, len);
 }
 
-static void xgene_cle_idt_to_hw(u32 dstqid, u32 fpsel,
+static void xgene_cle_idt_to_hw(struct xgene_enet_pdata *pdata,
+				u32 dstqid, u32 fpsel,
 				u32 nfpsel, u32 *idt_reg)
 {
-	*idt_reg =  SET_VAL(IDT_DSTQID, dstqid) |
-		    SET_VAL(IDT_FPSEL, fpsel) |
-		    SET_VAL(IDT_NFPSEL, nfpsel);
+	if (pdata->enet_id == XGENE_ENET1) {
+		*idt_reg = SET_VAL(IDT_DSTQID, dstqid) |
+			   SET_VAL(IDT_FPSEL1, fpsel)  |
+			   SET_VAL(IDT_NFPSEL1, nfpsel);
+	} else {
+		*idt_reg = SET_VAL(IDT_DSTQID, dstqid) |
+			   SET_VAL(IDT_FPSEL, fpsel)   |
+			   SET_VAL(IDT_NFPSEL, nfpsel);
+	}
 }
 
 static void xgene_cle_dbptr_to_hw(struct xgene_enet_pdata *pdata,
@@ -344,7 +351,7 @@ static int xgene_cle_set_rss_idt(struct xgene_enet_pdata *pdata)
 		nfpsel = 0;
 		idt_reg = 0;
 
-		xgene_cle_idt_to_hw(dstqid, fpsel, nfpsel, &idt_reg);
+		xgene_cle_idt_to_hw(pdata, dstqid, fpsel, nfpsel, &idt_reg);
 		ret = xgene_cle_dram_wr(&pdata->cle, &idt_reg, 1, i,
 					RSS_IDT, CLE_CMD_WR);
 		if (ret)
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
index 33c5f6b..9ac9f8e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
@@ -196,9 +196,13 @@ enum xgene_cle_ptree_dbptrs {
 #define IDT_DSTQID_POS		0
 #define IDT_DSTQID_LEN		12
 #define IDT_FPSEL_POS		12
-#define IDT_FPSEL_LEN		4
-#define IDT_NFPSEL_POS		16
-#define IDT_NFPSEL_LEN		4
+#define IDT_FPSEL_LEN		5
+#define IDT_NFPSEL_POS		17
+#define IDT_NFPSEL_LEN		5
+#define IDT_FPSEL1_POS		12
+#define IDT_FPSEL1_LEN		4
+#define IDT_NFPSEL1_POS		16
+#define IDT_NFPSEL1_LEN		4
 
 struct xgene_cle_ptree_branch {
 	bool valid;
-- 
1.9.1
