From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] ixgbe: inline the ixgbe_maybe_stop_tx function
Date: Thu, 21 Jul 2011 19:01:12 -0700
Message-ID: <1311300078-12876-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56055 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031Ab1GVCBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 22:01:23 -0400
In-Reply-To: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The ixgbe_maybe_stop_tx function is only a few lines long and is called
multiple times through the xmit hotpath.  In order to streamline things it
makes sense to just inline it.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f05ddf3..7275c5c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6785,7 +6785,7 @@ static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 	return 0;
 }
 
-static int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
+static inline int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 {
 	if (likely(ixgbe_desc_unused(tx_ring) >= size))
 		return 0;
-- 
1.7.6

