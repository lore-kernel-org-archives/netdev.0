From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/8] e1000: add dropped DMA receive enable back in for WoL
Date: Wed,  8 Feb 2012 01:36:31 -0800
Message-ID: <1328693798-27323-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dean Nelson <dnelson@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.stable.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:21470 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141Ab2BHJgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 04:36:44 -0500
In-Reply-To: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dean Nelson <dnelson@redhat.com>

Commit d5bc77a223b0e9b9dfb002048d2b34a79e7d0b48 broke Wake-on-LAN by
inadvertently dropping the enabling of DMA receives.

Restore the enabling of DMA receives for WoL.

This is applicable to 3.1+ stable trees.

CC: stable@vger.stable.org
Reported-by: Tobias Klausmann <klausman@schwarzvogel.de>
Signed-off-by: Dean Nelson <dnelson@redhat.com>
Tested-by: Tobias Klausmann <klausman@schwarzvogel.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 669ca38..d94d64b 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -4740,12 +4740,14 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		e1000_setup_rctl(adapter);
 		e1000_set_rx_mode(netdev);
 
+		rctl = er32(RCTL);
+
 		/* turn on all-multi mode if wake on multicast is enabled */
-		if (wufc & E1000_WUFC_MC) {
-			rctl = er32(RCTL);
+		if (wufc & E1000_WUFC_MC)
 			rctl |= E1000_RCTL_MPE;
-			ew32(RCTL, rctl);
-		}
+
+		/* enable receives in the hardware */
+		ew32(RCTL, rctl | E1000_RCTL_EN);
 
 		if (hw->mac_type >= e1000_82540) {
 			ctrl = er32(CTRL);
-- 
1.7.7.6
