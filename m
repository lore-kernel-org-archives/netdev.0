From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 3/8] qlcnic: Turn on promiscous mode for SRIOV PF.
Date: Fri, 10 Jan 2014 11:48:54 -0500
Message-ID: <1389372539-13753-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:18385 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752226AbaAJRXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:23:02 -0500
In-Reply-To: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o By default, SRIOV PF will have promiscous mode on.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 03eb2ad..ca22160 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1618,6 +1618,10 @@ int qlcnic_83xx_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
 
 	cmd->type = QLC_83XX_MBX_CMD_NO_WAIT;
 	qlcnic_83xx_set_interface_id_promisc(adapter, &temp);
+
+	if (qlcnic_84xx_check(adapter) && qlcnic_sriov_pf_check(adapter))
+		mode = VPORT_MISS_MODE_ACCEPT_ALL;
+
 	cmd->req.arg[1] = mode | temp;
 	err = qlcnic_issue_cmd(adapter, cmd);
 	if (!err)
-- 
1.8.3.1
