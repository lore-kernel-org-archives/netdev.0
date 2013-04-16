From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] atl1: Protect atl1_suspend with CONFIG_PM_SLEEP
Date: Tue, 16 Apr 2013 18:35:00 -0300
Message-ID: <1366148100-5617-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, joe@perches.com,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:47854 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965262Ab3DPVfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:35:33 -0400
Received: by mail-oa0-f49.google.com with SMTP id j6so996874oag.36
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:35:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

commit 7b7a2bbb690 (atl1: Remove unneeded PM_OPS definitions) removed the 
definition of atl1_suspend for the !CONFIG_PM_SLEEP case.

So only call atl1_suspend() when CONFIG_PM_SLEEP is defined and fix the 
following build error from randconfig:

drivers/net/ethernet/atheros/atlx/atl1.c: In function 'atl1_shutdown':
drivers/net/ethernet/atheros/atlx/atl1.c:2888:2: error: implicit declaration of function 'atl1_suspend' [-Werror=implicit-function-declaration]

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 9843c70..8338013 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2885,7 +2885,9 @@ static void atl1_shutdown(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
+#ifdef CONFIG_PM_SLEEP
 	atl1_suspend(&pdev->dev);
+#endif
 	pci_wake_from_d3(pdev, adapter->wol);
 	pci_set_power_state(pdev, PCI_D3hot);
 }
-- 
1.7.9.5
