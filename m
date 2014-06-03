From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/7] e1000: remove the check: skb->len<=0
Date: Tue,  3 Jun 2014 00:45:08 -0700
Message-ID: <1401781509-6435-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401781509-6435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yongjian Xu <xuyongjiande@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52586 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932407AbaFCHri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2014 03:47:38 -0400
In-Reply-To: <1401781509-6435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yongjian Xu <xuyongjiande@gmail.com>

There is no case skb->len would be 0 or 'negative'.
Remove the check.

Signed-off-by: Yongjian Xu <xuyongjiande@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 27058df..660971f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3105,11 +3105,6 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	 */
 	tx_ring = adapter->tx_ring;
 
-	if (unlikely(skb->len <= 0)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	/* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
 	 * packets may get corrupted during padding by HW.
 	 * To WA this issue, pad all small packets manually.
-- 
1.9.3
