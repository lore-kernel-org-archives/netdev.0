From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 5/5] bnxt_en: Add the ulp_sriov_cfg hooks for bnxt_re RDMA driver.
Date: Fri, 13 Jan 2017 01:32:04 -0500
Message-ID: <1484289124-28853-6-git-send-email-michael.chan@broadcom.com>
References: <1484289124-28853-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36799 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750700AbdAMGcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:32:20 -0500
Received: by mail-pf0-f181.google.com with SMTP id 189so26316550pfu.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:32:20 -0800 (PST)
In-Reply-To: <1484289124-28853-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ulp_sriov_cfg callbacks when the number of VFs is changing.  This
allows the RDMA driver to provision RDMA resources for the VFs.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 64ef0e5..0b8cd74 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -15,6 +15,7 @@
 #include <linux/etherdevice.h>
 #include "bnxt_hsi.h"
 #include "bnxt.h"
+#include "bnxt_ulp.h"
 #include "bnxt_sriov.h"
 #include "bnxt_ethtool.h"
 
@@ -555,6 +556,8 @@ static int bnxt_sriov_enable(struct bnxt *bp, int *num_vfs)
 	if (rc)
 		goto err_out2;
 
+	bnxt_ulp_sriov_cfg(bp, *num_vfs);
+
 	rc = pci_enable_sriov(bp->pdev, *num_vfs);
 	if (rc)
 		goto err_out2;
@@ -596,6 +599,8 @@ void bnxt_sriov_disable(struct bnxt *bp)
 	rtnl_lock();
 	bnxt_restore_pf_fw_resources(bp);
 	rtnl_unlock();
+
+	bnxt_ulp_sriov_cfg(bp, 0);
 }
 
 int bnxt_sriov_configure(struct pci_dev *pdev, int num_vfs)
-- 
1.8.3.1
