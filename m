From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 2/6] be2net: Issue COMMON_RESET_FUNCTION cmd during driver unload
Date: Wed,  7 Sep 2016 19:57:50 +0530
Message-ID: <20160907142754.13284-3-sriharsha.basavapatna@broadcom.com>
References: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:51437 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S935667AbcIGOpx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:45:53 -0400
In-Reply-To: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@broadcom.com>

As per SLI guideline, drivers need to issue COMMON_RESET_FUNCTION SLI
cmd during driver unload to clean up any non-persistent state
information.
Issue this cmd only if VFs are not assigned to VMs as it is possible
for PF driver to unload while it\'s VF remains functional and assigned
to a VM.

Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3be5d61..95d2fa3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5706,6 +5706,9 @@ static void be_remove(struct pci_dev *pdev)
 
 	be_clear(adapter);
 
+	if (!pci_vfs_assigned(adapter->pdev))
+		be_cmd_reset_function(adapter);
+
 	/* tell fw we're done with firing cmds */
 	be_cmd_fw_clean(adapter);
 
-- 
2.10.0.rc2.20.g5b18e70
