From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 3/5] qlcnic: Fix driver initialization for 83xx adapters
Date: Thu, 15 Aug 2013 08:27:27 -0400
Message-ID: <1376569649-565-4-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40588 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756276Ab3HONCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:02:08 -0400
In-Reply-To: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Load firmware from file before setting up interrupts.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index cc1e32a..17c26a1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2169,6 +2169,13 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	if (err)
 		goto detach_mbx;
 
+	if (!qlcnic_83xx_read_flash_descriptor_table(adapter))
+		qlcnic_83xx_read_flash_mfg_id(adapter);
+
+	err = qlcnic_83xx_idc_init(adapter);
+	if (err)
+		goto detach_mbx;
+
 	err = qlcnic_setup_intr(adapter, 0);
 	if (err) {
 		dev_err(&adapter->pdev->dev, "Failed to setup interrupt\n");
@@ -2186,13 +2193,6 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	/* register for NIC IDC AEN Events */
 	qlcnic_83xx_register_nic_idc_func(adapter, 1);
 
-	if (!qlcnic_83xx_read_flash_descriptor_table(adapter))
-		qlcnic_83xx_read_flash_mfg_id(adapter);
-
-	err = qlcnic_83xx_idc_init(adapter);
-	if (err)
-		goto disable_mbx_intr;
-
 	/* Configure default, SR-IOV or Virtual NIC mode of operation */
 	err = qlcnic_83xx_configure_opmode(adapter);
 	if (err)
-- 
1.8.1.4
