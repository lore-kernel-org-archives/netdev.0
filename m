From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] e1000e: low throughput using 4K jumbos on I218
Date: Sun, 28 Jul 2013 04:41:11 -0700
Message-ID: <1375011676-30739-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43491 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445Ab3G1Ll3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 07:41:29 -0400
In-Reply-To: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Alter the packet buffer allocation accordingly.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 99596a6..51b05fe 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3819,6 +3819,8 @@ void e1000e_reset(struct e1000_adapter *adapter)
 			break;
 		}
 
+		pba = 14;
+		ew32(PBA, pba);
 		fc->high_water = ((pba << 10) * 9 / 10) & E1000_FCRTH_RTH;
 		fc->low_water = ((pba << 10) * 8 / 10) & E1000_FCRTL_RTL;
 		break;
-- 
1.7.11.7
