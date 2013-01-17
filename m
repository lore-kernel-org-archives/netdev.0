From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] igb: Use in-kernel PTP_EV_PORT #define
Date: Thu, 17 Jan 2013 03:35:18 -0800
Message-ID: <1358422519-20981-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10828 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756147Ab3AQLfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 06:35:45 -0500
In-Reply-To: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Rather than use an extra #define for something that already exists, use the
kernel #define for the PTP port.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Acked-by: Jacob Keller <Jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 2ec53d7..5545abc 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/device.h>
 #include <linux/pci.h>
+#include <linux/ptp_classify.h>
 
 #include "igb.h"
 
@@ -698,7 +699,6 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 	else
 		wr32(E1000_ETQF(3), 0);
 
-#define PTP_PORT 319
 	/* L4 Queue Filter[3]: filter by destination port and protocol */
 	if (is_l4) {
 		u32 ftqf = (IPPROTO_UDP /* UDP */
@@ -707,12 +707,12 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 			| E1000_FTQF_MASK); /* mask all inputs */
 		ftqf &= ~E1000_FTQF_MASK_PROTO_BP; /* enable protocol check */
 
-		wr32(E1000_IMIR(3), htons(PTP_PORT));
+		wr32(E1000_IMIR(3), htons(PTP_EV_PORT));
 		wr32(E1000_IMIREXT(3),
 		     (E1000_IMIREXT_SIZE_BP | E1000_IMIREXT_CTRL_BP));
 		if (hw->mac.type == e1000_82576) {
 			/* enable source port check */
-			wr32(E1000_SPQF(3), htons(PTP_PORT));
+			wr32(E1000_SPQF(3), htons(PTP_EV_PORT));
 			ftqf &= ~E1000_FTQF_MASK_SOURCE_PORT_BP;
 		}
 		wr32(E1000_FTQF(3), ftqf);
-- 
1.7.11.7
