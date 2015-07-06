From: Suman Tripathi <stripathi@apm.com>
Subject: [PATCH net-next] drivers: net: xgene: Fix the compilation error "error: implicit declaration of function 'acpi_evaluate_integer'" for CONFIG_ACPI=n.
Date: Mon,  6 Jul 2015 13:34:22 +0530
Message-ID: <1436169862-1372-1-git-send-email-stripathi@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com, isubramanian@apm.com,
	Suman Tripathi <stripathi@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from denmail01-v4020.amcc.com ([192.195.68.30]:47883 "EHLO
	denmail01.amcc.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751225AbbGFIFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 04:05:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch guards the acpi_evaluate_interger function as it fails
the build for CONFIG_ACPI=n.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Suman Tripathi <stripathi@apm.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 4e83d4c..70b9ef6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -871,6 +871,7 @@ static const struct net_device_ops xgene_ndev_ops = {
 	.ndo_set_mac_address = xgene_enet_set_mac_address,
 };

+#ifdef CONFIG_ACPI
 static int xgene_get_port_id_acpi(struct device *dev,
 				  struct xgene_enet_pdata *pdata)
 {
@@ -886,6 +887,7 @@ static int xgene_get_port_id_acpi(struct device *dev,

 	return 0;
 }
+#endif

 static int xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdata *pdata)
 {
--
1.8.2.1
