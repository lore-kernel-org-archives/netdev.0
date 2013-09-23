From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] igbvf: add missing iounmap() on error in igbvf_probe()
Date: Mon, 23 Sep 2013 21:50:48 +0800
Message-ID: <CAPgLHd913mcS89QxCc8G5dDPmq5jY1CChdj9gGUPq0RH204gHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	davem@davemloft.net, mitch.a.williams@intel.com, kaber@trash.net,
	gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:57463 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926Ab3IWNuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 09:50:52 -0400
Received: by mail-bk0-f41.google.com with SMTP id na10so1185326bkb.14
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 06:50:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing iounmap() before return from igbvf_probe()
in the error handling case.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 95d5430..b0b1c99 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2700,7 +2700,7 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (ei->get_variants) {
 		err = ei->get_variants(adapter);
 		if (err)
-			goto err_ioremap;
+			goto err_get_variants;
 	}
 
 	/* setup adapter struct */
@@ -2797,6 +2797,7 @@ err_hw_init:
 	kfree(adapter->rx_ring);
 err_sw_init:
 	igbvf_reset_interrupt_capability(adapter);
+err_get_variants:
 	iounmap(adapter->hw.hw_addr);
 err_ioremap:
 	free_netdev(netdev);
