From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/2] bnxt_en: Call bnxt_dcb_init() after getting firmware DCBX configuration.
Date: Tue, 16 May 2017 16:39:43 -0400
Message-ID: <1494967184-12865-2-git-send-email-michael.chan@broadcom.com>
References: <1494967184-12865-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34887 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751767AbdEPUkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:40:22 -0400
Received: by mail-pg0-f49.google.com with SMTP id q125so62400599pgq.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:40:22 -0700 (PDT)
In-Reply-To: <1494967184-12865-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current code, bnxt_dcb_init() is called too early before we
determine if the firmware DCBX agent is running or not.  As a result,
we are not setting the DCB_CAP_DCBX_HOST and DCB_CAP_DCBX_LLD_MANAGED
flags properly to report to DCBNL.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index b56c54d..03f55da 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7630,8 +7630,6 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->min_mtu = ETH_ZLEN;
 	dev->max_mtu = BNXT_MAX_MTU;
 
-	bnxt_dcb_init(bp);
-
 #ifdef CONFIG_BNXT_SRIOV
 	init_waitqueue_head(&bp->sriov_cfg_wait);
 #endif
@@ -7669,6 +7667,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bnxt_hwrm_func_qcfg(bp);
 	bnxt_hwrm_port_led_qcaps(bp);
 	bnxt_ethtool_init(bp);
+	bnxt_dcb_init(bp);
 
 	bnxt_set_rx_skb_mode(bp, false);
 	bnxt_set_tpa_flags(bp);
-- 
1.8.3.1
