From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] ixgbe: Drop unnecessary addition from ixgbe_set_rx_buffer_len
Date: Fri, 19 Oct 2012 23:26:04 -0700
Message-ID: <1350714367-24208-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18923 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996Ab2JTG0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2012 02:26:41 -0400
In-Reply-To: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We still had some code floating around from the old single buffer receive
path.  As a result we were adding VLAN_HLEN to max_frame although the
resultant value was never used.  Since that is the case we can drop this from
the function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c1ce6e9..88d636a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3289,9 +3289,6 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_MHADD, mhadd);
 	}
 
-	/* MHADD will allow an extra 4 bytes past for vlan tagged frames */
-	max_frame += VLAN_HLEN;
-
 	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
 	/* set jumbo enable since MHADD.MFS is keeping size locked at max_frame */
 	hlreg0 |= IXGBE_HLREG0_JUMBOEN;
-- 
1.7.11.7
