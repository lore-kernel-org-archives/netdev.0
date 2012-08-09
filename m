From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 3/3] igb: Fix register defines for all non-82575 hardware
Date: Thu,  9 Aug 2012 02:39:12 -0700
Message-ID: <1344505152-28167-4-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38931 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756137Ab2HIJjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 05:39:22 -0400
In-Reply-To: <1344505152-28167-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It looks like the register defines for DCA were never updated after going from
82575 to 82576.  This change addresses that by updating the defines.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_regs.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 10efcd8..28394be 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -156,8 +156,12 @@
 				    : (0x0E018 + ((_n) * 0x40)))
 #define E1000_TXDCTL(_n)  ((_n) < 4 ? (0x03828 + ((_n) * 0x100)) \
 				    : (0x0E028 + ((_n) * 0x40)))
-#define E1000_DCA_TXCTRL(_n) (0x03814 + (_n << 8))
-#define E1000_DCA_RXCTRL(_n) (0x02814 + (_n << 8))
+#define E1000_RXCTL(_n)	  ((_n) < 4 ? (0x02814 + ((_n) * 0x100)) : \
+				      (0x0C014 + ((_n) * 0x40)))
+#define E1000_DCA_RXCTRL(_n)	E1000_RXCTL(_n)
+#define E1000_TXCTL(_n)   ((_n) < 4 ? (0x03814 + ((_n) * 0x100)) : \
+				      (0x0E014 + ((_n) * 0x40)))
+#define E1000_DCA_TXCTRL(_n) E1000_TXCTL(_n)
 #define E1000_TDWBAL(_n)  ((_n) < 4 ? (0x03838 + ((_n) * 0x100)) \
 				    : (0x0E038 + ((_n) * 0x40)))
 #define E1000_TDWBAH(_n)  ((_n) < 4 ? (0x0383C + ((_n) * 0x100)) \
-- 
1.7.11.2
