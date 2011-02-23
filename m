From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/5] atl1[ce]: fix sparse warnings
Date: Wed, 23 Feb 2011 11:06:49 -0800
Message-ID: <20110223190700.963792692@vyatta.com>
References: <20110223190647.482444598@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44644 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab1BWTxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 14:53:03 -0500
Content-Disposition: inline; filename=atl1c-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dmaw_block is an enum and max_pay_load is u32. Therefore
sparse gives warning about comparison of unsigned and signed value.
Resolve by using min_t to force cast.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/atl1c/atl1c_main.c	2011-02-23 09:58:11.282457630 -0800
+++ b/drivers/net/atl1c/atl1c_main.c	2011-02-23 09:58:42.626823758 -0800
@@ -1102,10 +1102,10 @@ static void atl1c_configure_tx(struct at
 	AT_READ_REG(hw, REG_DEVICE_CTRL, &dev_ctrl_data);
 	max_pay_load  = (dev_ctrl_data >> DEVICE_CTRL_MAX_PAYLOAD_SHIFT) &
 			DEVICE_CTRL_MAX_PAYLOAD_MASK;
-	hw->dmaw_block = min(max_pay_load, hw->dmaw_block);
+	hw->dmaw_block = min_t(u32, max_pay_load, hw->dmaw_block);
 	max_pay_load  = (dev_ctrl_data >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT) &
 			DEVICE_CTRL_MAX_RREQ_SZ_MASK;
-	hw->dmar_block = min(max_pay_load, hw->dmar_block);
+	hw->dmar_block = min_t(u32, max_pay_load, hw->dmar_block);
 
 	txq_ctrl_data = (hw->tpd_burst & TXQ_NUM_TPD_BURST_MASK) <<
 			TXQ_NUM_TPD_BURST_SHIFT;
--- a/drivers/net/atl1e/atl1e_main.c	2011-02-23 09:58:52.594940247 -0800
+++ b/drivers/net/atl1e/atl1e_main.c	2011-02-23 09:59:03.859071913 -0800
@@ -932,11 +932,11 @@ static inline void atl1e_configure_tx(st
 	max_pay_load  = ((dev_ctrl_data >> DEVICE_CTRL_MAX_PAYLOAD_SHIFT)) &
 			DEVICE_CTRL_MAX_PAYLOAD_MASK;
 
-	hw->dmaw_block = min(max_pay_load, hw->dmaw_block);
+	hw->dmaw_block = min_t(u32, max_pay_load, hw->dmaw_block);
 
 	max_pay_load  = ((dev_ctrl_data >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT)) &
 			DEVICE_CTRL_MAX_RREQ_SZ_MASK;
-	hw->dmar_block = min(max_pay_load, hw->dmar_block);
+	hw->dmar_block = min_t(u32, max_pay_load, hw->dmar_block);
 
 	if (hw->nic_type != athr_l2e_revB)
 		AT_WRITE_REGW(hw, REG_TXQ_CTRL + 2,


