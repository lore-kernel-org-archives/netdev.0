From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] igb: Fix a memory leak in igb_probe
Date: Wed,  5 Aug 2015 22:05:16 +0800
Message-ID: <1438783516-13283-1-git-send-email-baijiaju1990@163.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:36643 "EHLO m12-18.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbbHEOFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 10:05:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In error handling code of igb_probe, the memory adapter->shadow_vfta 
allocated by kcalloc in igb_sw_init is not freed. So when register_netdev 
or igb_init_i2c is failed, a memory leak will occur.
This patch adds kfree to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2f70a9b..3efb757 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2645,6 +2645,7 @@ err_eeprom:
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
 err_sw_init:
+	kfree(adapter->shadow_vfta);
 	igb_clear_interrupt_scheme(adapter);
 	pci_iounmap(pdev, hw->hw_addr);
 err_ioremap:
-- 
1.7.9.5
