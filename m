From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 1/5] qlcnic: Reinitialize mailbox data structures after firmware reset
Date: Thu, 15 Aug 2013 08:27:25 -0400
Message-ID: <1376569649-565-2-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:41226 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755403Ab3HONHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:07:08 -0400
In-Reply-To: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o After firmware reset VFs were failing to come up because of not
  reinitializing mailbox data structures. Reinitialize them so that
  VFs can come up after firmware reset.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 046286a..dc24979 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -1556,7 +1556,7 @@ static int qlcnic_sriov_vf_reinit_driver(struct qlcnic_adapter *adapter)
 {
 	int err;
 
-	set_bit(QLC_83XX_MBX_READY, &adapter->ahw->idc.status);
+	qlcnic_83xx_reinit_mbx_work(adapter->ahw->mailbox);
 	qlcnic_83xx_enable_mbx_interrupt(adapter);
 
 	err = qlcnic_sriov_cfg_bc_intr(adapter, 1);
-- 
1.8.1.4
