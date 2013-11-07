From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ixgbevf: use pci drvdata correctly in ixgbevf_suspend()
Date: Thu, 7 Nov 2013 16:13:24 +0800
Message-ID: <CAPgLHd8pjBBPwJ+Nn_Ld_YRyd4f_-cxh1U+9ARc5iDRsgXK4-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	davem@davemloft.net, kaber@trash.net, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:34449 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab3KGINZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 03:13:25 -0500
Received: by mail-bk0-f54.google.com with SMTP id 6so78275bkj.13
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 00:13:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

We had set the pci driver-specific data in ixgbevf_probe() as a type of
struct net_device, so we should use it as netdev in ixgbevf_suspend().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 59a62bb..a119ae4 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3197,8 +3197,8 @@ static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
 #ifdef CONFIG_PM
 static int ixgbevf_resume(struct pci_dev *pdev)
 {
-	struct ixgbevf_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev = adapter->netdev;
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
