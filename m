From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 12/24] ixgbe: fix bug with lots of tx queues
Date: Mon, 08 Sep 2008 21:48:04 -0700
Message-ID: <20080909044804.18904.96548.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.248]:59329 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbYIIEsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:06 -0400
Received: by hs-out-0708.google.com with SMTP id 4so428996hsl.5
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:06 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
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

