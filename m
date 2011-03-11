From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 04/11] e1000e: use dev_kfree_skb_irq() instead of dev_kfree_skb()
Date: Fri, 11 Mar 2011 03:06:23 -0800
Message-ID: <1299841590-30676-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	"Prasanna S. Panchamukhi" <prasanna.panchamukhi@riverbed.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21892 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512Ab1CKLGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:48 -0500
In-Reply-To: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Based on a report and patch originally submitted by Prasanna Panchamukhi.

Use dev_kfree_skb_irq() in e1000_clean_jumbo_rx_irq() since this latter
function is called only in interrupt context.  This avoids "Warning:
kfree_skb on hard IRQ" messages.

Cc: "Prasanna S. Panchamukhi" <prasanna.panchamukhi@riverbed.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 455d5a1..c43cdfe 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1322,7 +1322,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				/* an error means any chain goes out the window
 				 * too */
 				if (rx_ring->rx_skb_top)
-					dev_kfree_skb(rx_ring->rx_skb_top);
+					dev_kfree_skb_irq(rx_ring->rx_skb_top);
 				rx_ring->rx_skb_top = NULL;
 				goto next_desc;
 		}
@@ -1395,7 +1395,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		/* eth type trans needs skb->data to point to something */
 		if (!pskb_may_pull(skb, ETH_HLEN)) {
 			e_err("pskb_may_pull failed.\n");
-			dev_kfree_skb(skb);
+			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
 
-- 
1.7.4

