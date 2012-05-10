From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] ixgbe: correct disable_rx_buff timeout
Date: Wed,  9 May 2012 23:46:49 -0700
Message-ID: <1336632413-19135-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1282 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756132Ab2EJGrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 02:47:03 -0400
In-Reply-To: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The current value of the udelay timeout for ixgbe_disable_rx_buff is too
short. This causes the security path to not not be properly disabled during
the section that is meant to have it turned off. The end result causes a race
condition that results in RX issues.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index c7e51b8..77ac41f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -2561,7 +2561,7 @@ s32 ixgbe_disable_rx_buff_generic(struct ixgbe_hw *hw)
 			break;
 		else
 			/* Use interrupt-safe sleep just in case */
-			udelay(10);
+			udelay(1000);
 	}
 
 	/* For informational purposes only */
-- 
1.7.7.6
