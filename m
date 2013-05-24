From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 06/12] qlcnic: Convert nested if-else to switch-case
Date: Fri, 24 May 2013 03:04:30 -0400
Message-ID: <1369379076-4718-7-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0188.outbound.messaging.microsoft.com ([213.199.154.188]:7687
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759970Ab3EXH36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:29:58 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index 55e5e1b..b5054e1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -187,20 +187,24 @@ int qlcnic_83xx_config_vnic_opmode(struct qlcnic_adapter *adapter)
 	else
 		priv_level = QLC_83XX_GET_FUNC_PRIVILEGE(op_mode,
 							 ahw->pci_func);
-
-	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
+	switch (priv_level) {
+	case QLCNIC_NON_PRIV_FUNC:
 		ahw->op_mode = QLCNIC_NON_PRIV_FUNC;
 		ahw->idc.state_entry = qlcnic_83xx_idc_ready_state_entry;
 		nic_ops->init_driver = qlcnic_83xx_init_non_privileged_vnic;
-	} else if (priv_level == QLCNIC_PRIV_FUNC) {
+		break;
+	case QLCNIC_PRIV_FUNC:
 		ahw->op_mode = QLCNIC_PRIV_FUNC;
 		ahw->idc.state_entry = qlcnic_83xx_idc_vnic_pf_entry;
 		nic_ops->init_driver = qlcnic_83xx_init_privileged_vnic;
-	} else if (priv_level == QLCNIC_MGMT_FUNC) {
+		break;
+	case QLCNIC_MGMT_FUNC:
 		ahw->op_mode = QLCNIC_MGMT_FUNC;
 		ahw->idc.state_entry = qlcnic_83xx_idc_ready_state_entry;
 		nic_ops->init_driver = qlcnic_83xx_init_mgmt_vnic;
-	} else {
+		break;
+	default:
+		dev_err(&adapter->pdev->dev, "Invalid Virtual NIC opmode\n");
 		return -EIO;
 	}
 
@@ -209,8 +213,8 @@ int qlcnic_83xx_config_vnic_opmode(struct qlcnic_adapter *adapter)
 	else
 		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
 
-	adapter->ahw->idc.vnic_state = QLCNIC_DEV_NPAR_NON_OPER;
-	adapter->ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO;
+	ahw->idc.vnic_state = QLCNIC_DEV_NPAR_NON_OPER;
+	ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO;
 
 	return 0;
 }
-- 
1.5.6
