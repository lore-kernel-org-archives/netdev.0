From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 8/8] qlcnic: Dump mailbox registers when mailbox command times out.
Date: Mon, 16 Dec 2013 15:37:03 -0500
Message-ID: <34223decf96f668799808aec23c31acc41d282aa.1387256276.git.himanshu.madhani@qlogic.com>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:41545 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751636Ab3LPVJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:53 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index ab66e7f..6055d39 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3734,6 +3734,19 @@ static void qlcnic_83xx_decode_mbx_rsp(struct qlcnic_adapter *adapter,
 	return;
 }
 
+static inline void qlcnic_dump_mailbox_registers(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	u32 offset;
+
+	offset = QLCRDX(ahw, QLCNIC_DEF_INT_MASK);
+	dev_info(&adapter->pdev->dev, "Mbx interrupt mask=0x%x, Mbx interrupt enable=0x%x, Host mbx control=0x%x, Fw mbx control=0x%x",
+		 readl(ahw->pci_base0 + offset),
+		 QLCRDX(ahw, QLCNIC_MBX_INTR_ENBL),
+		 QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL),
+		 QLCRDX(ahw, QLCNIC_FW_MBX_CTRL));
+}
+
 static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 {
 	struct qlcnic_mailbox *mbx = container_of(work, struct qlcnic_mailbox,
@@ -3778,6 +3791,8 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 				__func__, cmd->cmd_op, cmd->type, ahw->pci_func,
 				ahw->op_mode);
 			clear_bit(QLC_83XX_MBX_READY, &mbx->status);
+			qlcnic_dump_mailbox_registers(adapter);
+			qlcnic_83xx_get_mbx_data(adapter, cmd);
 			qlcnic_dump_mbx(adapter, cmd);
 			qlcnic_83xx_idc_request_reset(adapter,
 						      QLCNIC_FORCE_FW_DUMP_KEY);
-- 
1.8.1.4
