From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] i40e: clear NVM update state on ethtool test
Date: Tue,  9 Dec 2014 03:22:38 -0800
Message-ID: <1418124170-7495-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43344 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756575AbaLILW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 06:22:56 -0500
In-Reply-To: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Once in a great while the NVMUpdate tools and the driver get out
of phase with each other.  This gives us a way to reset things
without having to unload the driver.

Change-ID: I353f688236249a666a90ba3e7233e0ed8c1a04e9
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index fcd815d..25242f5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1393,6 +1393,9 @@ static int i40e_eeprom_test(struct net_device *netdev, u64 *data)
 	netif_info(pf, hw, netdev, "eeprom test\n");
 	*data = i40e_diag_eeprom_test(&pf->hw);
 
+	/* forcebly clear the NVM Update state machine */
+	pf->hw.nvmupd_state = I40E_NVMUPD_STATE_INIT;
+
 	return *data;
 }
 
-- 
1.9.3
