From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] igb: Fix a memory leak in igb_probe
Date: Tue, 18 Aug 2015 14:09:18 -0700
Message-ID: <1439932162-1995-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61611 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753950AbbHRVJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:45 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>

In error handling code of igb_probe, the memory adapter->shadow_vfta
allocated by kcalloc in igb_sw_init is not freed. So when register_netdev
or igb_init_i2c is failed, a memory leak will occur.
This patch adds kfree to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 17c1c84..1ebdb46 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2649,6 +2649,7 @@ err_eeprom:
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
 err_sw_init:
+	kfree(adapter->shadow_vfta);
 	igb_clear_interrupt_scheme(adapter);
 	pci_iounmap(pdev, hw->hw_addr);
 err_ioremap:
-- 
2.4.3
