From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net 1/4] qlcnic: Fix initialization of work function.
Date: Fri, 26 Jul 2013 16:24:00 -0400
Message-ID: <0562929dee35fa70865505d43d13337c0d50c79c.1374891091.git.himanshu.madhani@qlogic.com>
References: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53166 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933362Ab3GZV0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:26:23 -0400
In-Reply-To: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Work function needs to be initialized before we participate in
inter device communication (IDC).

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index f41dfab..51ab4b5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2123,6 +2123,8 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	set_bit(QLC_83XX_MBX_READY, &adapter->ahw->idc.status);
 	qlcnic_83xx_clear_function_resources(adapter);
 
+	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
+
 	/* register for NIC IDC AEN Events */
 	qlcnic_83xx_register_nic_idc_func(adapter, 1);
 
@@ -2140,8 +2142,6 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	if (adapter->nic_ops->init_driver(adapter))
 		return -EIO;
 
-	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
-
 	/* Periodically monitor device status */
 	qlcnic_83xx_idc_poll_dev_state(&adapter->fw_work.work);
 
-- 
1.8.1.4
