From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 2/8] qlcnic: fix firmware based IDC participation
Date: Sat,  9 Feb 2013 14:29:49 -0500
Message-ID: <1360438195-12667-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:14783 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932485Ab3BITvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Feb 2013 14:51:18 -0500
In-Reply-To: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Driver needs to stop participating in firmware based Inter Driver
Communication (IDC) while unloading driver

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 714124a..dcb990d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2023,6 +2023,8 @@ static void qlcnic_remove(struct pci_dev *pdev)
 		if (adapter->flags & QLCNIC_MSIX_ENABLED)
 			qlcnic_83xx_config_intrpt(adapter, 0);
 		qlcnic_83xx_free_mbx_intr(adapter);
+		qlcnic_83xx_register_nic_idc_func(adapter, 0);
+		cancel_delayed_work_sync(&adapter->idc_aen_work);
 	}
 
 	qlcnic_detach(adapter);
@@ -2180,10 +2182,6 @@ static int qlcnic_close(struct net_device *netdev)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
 	__qlcnic_down(adapter, netdev);
-	if (qlcnic_83xx_check(adapter)) {
-		qlcnic_83xx_register_nic_idc_func(adapter, 0);
-		cancel_delayed_work_sync(&adapter->idc_aen_work);
-	}
 
 	return 0;
 }
@@ -3117,6 +3115,8 @@ static pci_ers_result_t qlcnic_io_error_detected(struct pci_dev *pdev,
 		if (adapter->flags & QLCNIC_MSIX_ENABLED)
 			qlcnic_83xx_config_intrpt(adapter, 0);
 		qlcnic_83xx_free_mbx_intr(adapter);
+		qlcnic_83xx_register_nic_idc_func(adapter, 0);
+		cancel_delayed_work_sync(&adapter->idc_aen_work);
 	}
 
 	qlcnic_detach(adapter);
-- 
1.7.1
