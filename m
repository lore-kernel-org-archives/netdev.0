From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/5] e1000e: NVM write protect access removed from SPT HW
Date: Fri, 20 Mar 2015 17:57:43 -0700
Message-ID: <1426899465-15789-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Kristen Carlson Accardi <kristen@linux.intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:52848 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916AbbCUA56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 20:57:58 -0400
In-Reply-To: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

The call to e1000e_write_protect_nvm_ich8lan() is no longer supported by HW.
Access to these registers causes a system freeze in A step hardware and is
ignored in B step hardware. This function must not be called in hardware
newer than LPT.

CC: Kristen Carlson Accardi <kristen@linux.intel.com>
Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 8c95fb8..4e56c31 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6874,7 +6874,8 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_hw_init;
 
 	if ((adapter->flags & FLAG_IS_ICH) &&
-	    (adapter->flags & FLAG_READ_ONLY_NVM))
+	    (adapter->flags & FLAG_READ_ONLY_NVM) &&
+	    (hw->mac.type < e1000_pch_spt))
 		e1000e_write_protect_nvm_ich8lan(&adapter->hw);
 
 	hw->mac.ops.get_bus_info(&adapter->hw);
-- 
1.9.3
