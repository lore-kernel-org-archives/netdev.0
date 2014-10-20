From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Subject: [PATCH 1/1] e1000: unset IFF_UNICAST_FLT on WMware 82545EM
Date: Mon, 20 Oct 2014 15:11:15 -0700
Message-ID: <20141020221115.1FC9B480090@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	pv-drivers@vmware.com, linux.nics@intel.com, fruggeri@arista.com,
	e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

VMWare's e1000 implementation does not seem to support unicast filtering.
This can be observed by configuring a macvlan interface on eth0 in a VM in
VMWare Fusion 5.0.5, and trying to use that interface instead of eth0.
Tested on 3.16.

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
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
1.8.1.4
