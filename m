From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 05/25] ixgb: check down state before enable irq
Date: Tue, 08 Jul 2008 15:51:27 -0700
Message-ID: <20080708225127.6925.46055.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43513 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426AbYGHWv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:28 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

in order to prevent the case where poll_disable is waiting
on our device to permanently, check the flag to make sure we're not
down or closing down before re-enabling interrupts.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index ec8bce1..60cad65 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1782,7 +1782,8 @@ ixgb_clean(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
-		ixgb_irq_enable(adapter);
+		if (!test_bit(__IXGB_DOWN, &adapter->flags))
+			ixgb_irq_enable(adapter);
 	}
 
 	return work_done;

