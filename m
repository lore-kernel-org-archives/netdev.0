From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] i40evf: use pci drvdata correctly in i40evf_suspend()
Date: Tue, 7 Jan 2014 16:53:01 +0800
Message-ID: <CAPgLHd-DEjDxA-9=O_Yqd-9Nc4Q-Xt1kXXcQj7Kc4ig070KQmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:43681 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbaAGIxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 03:53:03 -0500
Received: by mail-bk0-f54.google.com with SMTP id v16so138996bkz.27
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 00:53:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

We had set the pci driver-specific data in i40evf_probe() as
a type of struct net_device, so we should use it as netdev
in i40evf_resume().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 06bf8253..a495ec4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2216,8 +2216,8 @@ static int i40evf_suspend(struct pci_dev *pdev, pm_message_t state)
  **/
 static int i40evf_resume(struct pci_dev *pdev)
 {
-	struct i40evf_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev = adapter->netdev;
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
