From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 1/3] qlcnic: Fix set driver version command
Date: Thu, 15 Aug 2013 08:29:27 -0400
Message-ID: <1376569769-625-2-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1376569769-625-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40607 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756829Ab3HONCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:02:17 -0400
In-Reply-To: <1376569769-625-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Driver was issuing set driver version command through all
functions in the adapter. Fix the driver to issue set driver
version once per adapter, through function 0.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      | 6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 9f4b8d5..345d987 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -629,7 +629,8 @@ int qlcnic_83xx_idc_reattach_driver(struct qlcnic_adapter *adapter)
 		return -EIO;
 	}
 
-	qlcnic_set_drv_version(adapter);
+	if (adapter->portnum == 0)
+		qlcnic_set_drv_version(adapter);
 	qlcnic_83xx_idc_attach_driver(adapter);
 
 	return 0;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index ee013fc..bc05d01 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2165,7 +2165,8 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_out_disable_mbx_intr;
 
-	qlcnic_set_drv_version(adapter);
+	if (adapter->portnum == 0)
+		qlcnic_set_drv_version(adapter);
 
 	pci_set_drvdata(pdev, adapter);
 
@@ -3085,7 +3086,8 @@ done:
 	adapter->fw_fail_cnt = 0;
 	adapter->flags &= ~QLCNIC_FW_HANG;
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	qlcnic_set_drv_version(adapter);
+	if (adapter->portnum == 0)
+		qlcnic_set_drv_version(adapter);
 
 	if (!qlcnic_clr_drv_state(adapter))
 		qlcnic_schedule_work(adapter, qlcnic_fw_poll_work,
-- 
1.8.1.4
