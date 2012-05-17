From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/4] igb: Disable the BMC-to-OS Watchdog Enable bit for DMAC.
Date: Thu, 17 May 2012 05:31:52 -0700
Message-ID: <1337257912-8487-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1337257912-8487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56414 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760765Ab2EQMb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 08:31:57 -0400
In-Reply-To: <1337257912-8487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Under certain scenarios, it's possible that bursty manageability traffic
over the BMC-to-OS path may overrun the internal manageability receive
buffer causing dropped manageability packets. Clearing this bit prevents
this situation by interrupting coalescing to allow manageability traffic
through.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_defines.h |    2 ++
 drivers/net/ethernet/intel/igb/igb_main.c      |    3 +++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 6409f85..ec7e4fe 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -301,6 +301,8 @@
 							* transactions */
 #define E1000_DMACR_DMAC_LX_SHIFT       28
 #define E1000_DMACR_DMAC_EN             0x80000000 /* Enable DMA Coalescing */
+/* DMA Coalescing BMC-to-OS Watchdog Enable */
+#define E1000_DMACR_DC_BMC2OSW_EN	0x00008000
 
 #define E1000_DMCTXTH_DMCTTHR_MASK      0x00000FFF /* DMA Coalescing Transmit
 							* Threshold */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 9bbf1a2..dd3bfe8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7147,6 +7147,9 @@ static void igb_init_dmac(struct igb_adapter *adapter, u32 pba)
 
 			/* watchdog timer= +-1000 usec in 32usec intervals */
 			reg |= (1000 >> 5);
+
+			/* Disable BMC-to-OS Watchdog Enable */
+			reg &= ~E1000_DMACR_DC_BMC2OSW_EN;
 			wr32(E1000_DMACR, reg);
 
 			/*
-- 
1.7.7.6
