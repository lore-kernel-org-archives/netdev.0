From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/5] qlcnic: Fix usage of use_msi and use_msi_x module parameters
Date: Fri, 21 Feb 2014 01:23:05 -0500
Message-ID: <1392963788-18341-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:6898 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874AbaBUG6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 01:58:36 -0500
In-Reply-To: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Once interrupts are enabled, instead of using module parameters,
use flags (QLCNIC_MSI_ENABLED and QLCNIC_MSIX_ENABLED) set by driver
to check interrupt mode.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 149c4b6..e10fc8e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3863,7 +3863,7 @@ int qlcnic_validate_rings(struct qlcnic_adapter *adapter, __u32 ring_cnt,
 		strcpy(buf, "Tx");
 	}
 
-	if (!qlcnic_use_msi_x && !qlcnic_use_msi) {
+	if (!QLCNIC_IS_MSI_FAMILY(adapter)) {
 		netdev_err(netdev, "No RSS/TSS support in INT-x mode\n");
 		return -EINVAL;
 	}
-- 
1.8.1.4
