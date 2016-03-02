From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/6] qed: Remove unused NVM vendor ID
Date: Wed, 2 Mar 2016 20:26:04 +0200
Message-ID: <1456943165-15198-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:62635 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756359AbcCBS0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:26:30 -0500
In-Reply-To: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove 2 unused fields from driver code.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h     | 3 ---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 7 -------
 2 files changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 66b021e..e5604ee 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -146,9 +146,6 @@ struct qed_hw_info {
 	u16				ovlan;
 	u32				part_num[4];
 
-	u32				vendor_id;
-	u32				device_id;
-
 	unsigned char			hw_mac_addr[ETH_ALEN];
 
 	struct qed_igu_info		*p_igu_info;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index c3f293d..b7d100f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1083,13 +1083,6 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_hwfn,
 	/* Read nvm_cfg1  (Notice this is just offset, and not offsize (TBD) */
 	nvm_cfg1_offset = qed_rd(p_hwfn, p_ptt, nvm_cfg_addr + 4);
 
-	/* Read Vendor Id / Device Id */
-	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
-	       offsetof(struct nvm_cfg1, glob) +
-	       offsetof(struct nvm_cfg1_glob, pci_id);
-	p_hwfn->hw_info.vendor_id = qed_rd(p_hwfn, p_ptt, addr) &
-				    NVM_CFG1_GLOB_VENDOR_ID_MASK;
-
 	addr = MCP_REG_SCRATCH + nvm_cfg1_offset +
 	       offsetof(struct nvm_cfg1, glob) +
 	       offsetof(struct nvm_cfg1_glob, core_cfg);
-- 
1.9.3
