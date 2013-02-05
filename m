From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] ixgbe: Replace rmb in Tx cleanup with read_barrier_depends
Date: Tue,  5 Feb 2013 02:02:27 -0800
Message-ID: <1360058548-18158-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:25253 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718Ab3BEKDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 05:03:04 -0500
In-Reply-To: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The rmb in the Tx cleanup path is a much stronger barrier than we really need.
All that is really needed is a read_barrier_depends since the location of the
EOP descriptor is dependent on the eop_desc value.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 88500dd..ef9cb0a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -838,7 +838,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			break;
 
 		/* prevent any other reads prior to eop_desc */
-		rmb();
+		read_barrier_depends();
 
 		/* if DD is not set pending work has not been completed */
 		if (!(eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)))
-- 
1.7.11.7
