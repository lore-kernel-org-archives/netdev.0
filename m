From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/6] bnxt_en: Fix VF PCIe link speed and width logic.
Date: Fri, 13 Oct 2017 21:09:31 -0400
Message-ID: <1507943374-13308-4-git-send-email-michael.chan@broadcom.com>
References: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org,
        Vasundhara Volam <vasundhara-v.volam@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:49439 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753250AbdJNBJt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 21:09:49 -0400
Received: by mail-qt0-f178.google.com with SMTP id k31so22656691qta.6
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 18:09:48 -0700 (PDT)
In-Reply-To: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara-v.volam@broadcom.com>

PCIE PCIE_EP_REG_LINK_STATUS_CONTROL register is only defined in PF
config space, so we must read it from the PF.

Fixes: 90c4f788f6c0 ("bnxt_en: Report PCIe link speed and width during driver load")
Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 3f596de..4ffa0b1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7965,7 +7965,7 @@ static void bnxt_parse_log_pcie_link(struct bnxt *bp)
 	enum pcie_link_width width = PCIE_LNK_WIDTH_UNKNOWN;
 	enum pci_bus_speed speed = PCI_SPEED_UNKNOWN;
 
-	if (pcie_get_minimum_link(bp->pdev, &speed, &width) ||
+	if (pcie_get_minimum_link(pci_physfn(bp->pdev), &speed, &width) ||
 	    speed == PCI_SPEED_UNKNOWN || width == PCIE_LNK_WIDTH_UNKNOWN)
 		netdev_info(bp->dev, "Failed to determine PCIe Link Info\n");
 	else
-- 
1.8.3.1
