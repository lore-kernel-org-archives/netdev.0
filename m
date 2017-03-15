From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 2/7] drivers: net: xgene: Fix hardware checksum setting
Date: Wed, 15 Mar 2017 13:27:16 -0700
Message-ID: <1489609641-31557-3-git-send-email-isubramanian@apm.com>
References: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, qnguyen@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33926 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdCOU0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:26:07 -0400
Received: by mail-pf0-f171.google.com with SMTP id v190so13687803pfb.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:26:06 -0700 (PDT)
In-Reply-To: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch fixes the hardware checksum settings by properly program
the classifier. Otherwise, packet may be received with checksum error
on X-Gene1 SoC.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 06e6816..c72a17e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -623,6 +623,7 @@ static void xgene_enet_cle_bypass(struct xgene_enet_pdata *pdata,
 	xgene_enet_rd_csr(pdata, CLE_BYPASS_REG0_0_ADDR, &cb);
 	cb |= CFG_CLE_BYPASS_EN0;
 	CFG_CLE_IP_PROTOCOL0_SET(&cb, 3);
+	CFG_CLE_IP_HDR_LEN_SET(&cb, 0);
 	xgene_enet_wr_csr(pdata, CLE_BYPASS_REG0_0_ADDR, cb);
 
 	xgene_enet_rd_csr(pdata, CLE_BYPASS_REG1_0_ADDR, &cb);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 5f83037..b6cd625 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -163,6 +163,7 @@ enum xgene_enet_rm {
 #define CFG_RXCLK_MUXSEL0_SET(dst, val)	xgene_set_bits(dst, val, 26, 3)
 
 #define CFG_CLE_IP_PROTOCOL0_SET(dst, val)	xgene_set_bits(dst, val, 16, 2)
+#define CFG_CLE_IP_HDR_LEN_SET(dst, val)	xgene_set_bits(dst, val, 8, 5)
 #define CFG_CLE_DSTQID0_SET(dst, val)		xgene_set_bits(dst, val, 0, 12)
 #define CFG_CLE_FPSEL0_SET(dst, val)		xgene_set_bits(dst, val, 16, 4)
 #define CFG_CLE_NXTFPSEL0_SET(dst, val)		xgene_set_bits(dst, val, 20, 4)
-- 
1.9.1
