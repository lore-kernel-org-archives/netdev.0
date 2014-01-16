From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 3/6] ixgbevf: use pci drvdata correctly in ixgbevf_suspend()
Date: Thu, 16 Jan 2014 02:30:07 -0800
Message-ID: <1389868210-24035-4-git-send-email-aaron.f.brown@intel.com>
References: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46417 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbaAPKaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 05:30:35 -0500
In-Reply-To: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

We had set the pci driver-specific data in ixgbevf_probe() as a type of
struct net_device, so we should use it as netdev in ixgbevf_suspend().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a5d3167..74af295 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3222,8 +3222,8 @@ static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
 #ifdef CONFIG_PM
 static int ixgbevf_resume(struct pci_dev *pdev)
 {
-	struct ixgbevf_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev = adapter->netdev;
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
-- 
1.8.5.GIT
