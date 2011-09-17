From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] ixgbe: Add SFP support for missed 82598 PHY
Date: Fri, 16 Sep 2011 19:15:47 -0700
Message-ID: <1316225752-1709-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42810 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755326Ab1IQCP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 22:15:59 -0400
In-Reply-To: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

One of the 82598 phys was not being correctly identified as being SFP.
This change corrects that.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0533bc4..ce59dc6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3451,6 +3451,9 @@ static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
 	case ixgbe_phy_sfp_active_unknown:
 	case ixgbe_phy_sfp_ftl_active:
 		return true;
+	case ixgbe_phy_nl:
+		if (hw->mac.type == ixgbe_mac_82598EB)
+			return true;
 	default:
 		return false;
 	}
-- 
1.7.6
