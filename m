From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] igb: do a reset on SR-IOV re-init if device is down
Date: Thu, 10 Jul 2014 03:29:39 -0700
Message-ID: <1404988179-2640-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	stable <stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Assmann <sassmann@kpanic.de>

To properly re-initialize SR-IOV it is necessary to reset the device
even if it is already down. Not doing this may result in Tx unit hangs.

Cc: stable <stable@vger.kernel.org>
Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 57a96e0..a9537ba 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7592,6 +7592,8 @@ static int igb_sriov_reinit(struct pci_dev *dev)
 
 	if (netif_running(netdev))
 		igb_close(netdev);
+	else
+		igb_reset(adapter);
 
 	igb_clear_interrupt_scheme(adapter);
 
-- 
1.9.3
