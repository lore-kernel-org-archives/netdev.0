From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 2/8] qlcnic: Fix diagnostic test for all adapters.
Date: Mon, 16 Dec 2013 15:36:57 -0500
Message-ID: <f250b8b325e02ffc40c2f37e67444a7d59e00c70.1387256276.git.himanshu.madhani@qlogic.com>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:5136 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752143Ab3LPVJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:53 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Driver should re-allocate all Tx queues after completing
  diagnostic tests. This regression was added by commit id
  c2c5e3a0681bb1945c0cb211a5f4baa22cb2cbb3 ("qlcnic: Enable
  diagnostic test for multiple Tx queues.")

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c | 2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 1 -
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index b36c02f..6d3edf6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -948,6 +948,7 @@ static int qlcnic_irq_test(struct net_device *netdev)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_cmd_args cmd;
 	int ret, drv_sds_rings = adapter->drv_sds_rings;
+	int drv_tx_rings = adapter->drv_tx_rings;
 
 	if (qlcnic_83xx_check(adapter))
 		return qlcnic_83xx_interrupt_test(netdev);
@@ -980,6 +981,7 @@ free_diag_res:
 
 clear_diag_irq:
 	adapter->drv_sds_rings = drv_sds_rings;
+	adapter->drv_tx_rings = drv_tx_rings;
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
 	return ret;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 05c1eef..aa019c3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1940,7 +1940,6 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	qlcnic_detach(adapter);
 
 	adapter->drv_sds_rings = QLCNIC_SINGLE_RING;
-	adapter->drv_tx_rings = QLCNIC_SINGLE_RING;
 	adapter->ahw->diag_test = test;
 	adapter->ahw->linkup = 0;
 
-- 
1.8.1.4
