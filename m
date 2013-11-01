From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] e1000: fix wrong queue idx calculation
Date: Fri,  1 Nov 2013 06:56:45 -0700
Message-ID: <1383314210-24289-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Hong Zhiguo <zhiguohong@tencent.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12204 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371Ab3KAN4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 09:56:54 -0400
In-Reply-To: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <zhiguohong@tencent.com>

tx_ring and adapter->tx_ring are already of type "struct
e1000_tx_ring *"

Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 59ad007..ad6800a 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3917,8 +3917,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			      "  next_to_watch        <%x>\n"
 			      "  jiffies              <%lx>\n"
 			      "  next_to_watch.status <%x>\n",
-				(unsigned long)((tx_ring - adapter->tx_ring) /
-					sizeof(struct e1000_tx_ring)),
+				(unsigned long)(tx_ring - adapter->tx_ring),
 				readl(hw->hw_addr + tx_ring->tdh),
 				readl(hw->hw_addr + tx_ring->tdt),
 				tx_ring->next_to_use,
-- 
1.8.3.1
