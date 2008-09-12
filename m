From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 12/29] ixgbe: fix bug with lots of tx queues
Date: Thu, 11 Sep 2008 19:58:29 -0700
Message-ID: <20080912025817.6234.36245.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:45474 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440AbYILC6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:58:31 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392897waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:58:31 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

when using more than 8 tx queues you can overrun the 8 bit v_idx
field, so change it to 16 bits to represent the maximum number
of queues (one for each bit)

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 5ba0384..064af67 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -152,9 +152,9 @@ struct ixgbe_ring {
 	struct net_lro_mgr lro_mgr;
 	bool lro_used;
 	struct ixgbe_queue_stats stats;
-	u8 v_idx; /* maps directly to the index for this ring in the hardware
-		   * vector array, can also be used for finding the bit in EICR
-		   * and friends that represents the vector for this ring */
+	u16 v_idx; /* maps directly to the index for this ring in the hardware
+	           * vector array, can also be used for finding the bit in EICR
+	           * and friends that represents the vector for this ring */
 
 
 	u16 work_limit;                /* max work per interrupt */

