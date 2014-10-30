From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/4] e1000: unset IFF_UNICAST_FLT on WMware 82545EM
Date: Thu, 30 Oct 2014 05:33:53 -0700
Message-ID: <1414672436-20616-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Francesco Ruggeri <fruggeri@arista.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7296 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759212AbaJ3Md7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 08:33:59 -0400
In-Reply-To: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Ruggeri <fruggeri@aristanetworks.com>

VMWare's e1000 implementation does not seem to support unicast filtering.
This can be observed by configuring a macvlan interface on eth0 in a VM in
VMWare Fusion 5.0.5, and trying to use that interface instead of eth0.
Tested on 3.16.

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 5f6aded..24f3986 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1075,7 +1075,10 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				  NETIF_F_HW_CSUM |
 				  NETIF_F_SG);
 
-	netdev->priv_flags |= IFF_UNICAST_FLT;
+	/* Do not set IFF_UNICAST_FLT for VMWare's 82545EM */
+	if (hw->device_id != E1000_DEV_ID_82545EM_COPPER ||
+	    hw->subsystem_vendor_id != PCI_VENDOR_ID_VMWARE)
+		netdev->priv_flags |= IFF_UNICAST_FLT;
 
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(hw);
 
-- 
1.9.3
