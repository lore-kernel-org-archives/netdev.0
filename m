From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] ixgbe: need not repeat init skb with NULL
Date: Thu, 30 Oct 2014 05:33:55 -0700
Message-ID: <1414672436-20616-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Junwei Zhang <linggao.zjw@alibaba-inc.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Martin Zhang <martinbj2008@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7296 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932961AbaJ3Md7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 08:33:59 -0400
In-Reply-To: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junwei Zhang <linggao.zjw@alibaba-inc.com>

Signed-off-by: Martin Zhang <martinbj2008@gmail.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fec5212..d2df4e3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4321,8 +4321,8 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 				IXGBE_CB(skb)->page_released = false;
 			}
 			dev_kfree_skb(skb);
+			rx_buffer->skb = NULL;
 		}
-		rx_buffer->skb = NULL;
 		if (rx_buffer->dma)
 			dma_unmap_page(dev, rx_buffer->dma,
 				       ixgbe_rx_pg_size(rx_ring),
-- 
1.9.3
