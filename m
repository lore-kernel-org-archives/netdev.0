From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next] igb: do a reset on SR-IOV re-init if device is down
Date: Tue,  1 Jul 2014 13:45:49 +0200
Message-ID: <1404215149-20634-1-git-send-email-sassmann@kpanic.de>
Cc: davem@davemloft.net, e1000-devel@lists.sourceforge.net,
	carolyn.wyborny@intel.com, jeffrey.t.kirsher@intel.com,
	sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003AbaGALwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:52:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To properly re-initialize SR-IOV it is necessary to reset the device
even if it is already down. Not doing this may result in tx unit hangs.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index f145adb..6f3cf45 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7578,6 +7578,8 @@ static int igb_sriov_reinit(struct pci_dev *dev)
 
 	if (netif_running(netdev))
 		igb_close(netdev);
+	else
+		igb_reset(adapter);
 
 	igb_clear_interrupt_scheme(adapter);
 
-- 
1.9.3
