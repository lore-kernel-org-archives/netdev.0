From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgbe: Do not use DCA to prefetch the entire packet into the cache
Date: Tue, 13 Nov 2012 06:03:15 -0800
Message-ID: <1352815405-751-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8266 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644Ab2KMOD2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:03:28 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The way the code was previously written it was causing DCA to prefetch the
entire packet into the cache when it was enabled.  That is excessive as we
only really need the headers.

We are now prefetching the headers via software so doing this from DCA would
be redundant anyway.  So clear the bit that was causing us to prefetch the
packet data and instead only use DCA for the descriptor rings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 690535a..38fc186 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1015,7 +1015,6 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 	 * which will cause the DCA tag to be cleared.
 	 */
 	rxctrl |= IXGBE_DCA_RXCTRL_DESC_RRO_EN |
-		  IXGBE_DCA_RXCTRL_DATA_DCA_EN |
 		  IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 
 	IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(reg_idx), rxctrl);
-- 
1.7.11.7
