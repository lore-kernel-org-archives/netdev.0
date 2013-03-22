From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 1/5] qlcnic: Fix configure mailbox interrupt command for 83xx adapter
Date: Fri, 22 Mar 2013 11:57:53 -0400
Message-ID: <1363967877-16812-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Manish chopra <manish.chopra@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:20000 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933882Ab3CVQVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 12:21:03 -0400
In-Reply-To: <1363967877-16812-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

o Due to improper data type of variable "type", interrupt resources were
  not getting deleted in hardware which was causing resource exhaustion
  in hardware. Hence mailbox command fails after some iterations of context change.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 56c3676..8de8ca5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2111,9 +2111,8 @@ int qlcnic_83xx_get_pci_info(struct qlcnic_adapter *adapter,
 int qlcnic_83xx_config_intrpt(struct qlcnic_adapter *adapter, bool op_type)
 {
 	int i, index, err;
-	bool type;
 	u8 max_ints;
-	u32 val, temp;
+	u32 val, temp, type;
 	struct qlcnic_cmd_args cmd;
 
 	max_ints = adapter->ahw->num_msix - 1;
-- 
1.5.6
