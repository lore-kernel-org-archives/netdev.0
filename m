From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] igb: Drop unnecessary checks in transmit path
Date: Mon, 15 Feb 2016 19:21:53 -0800
Message-ID: <1455592915-82261-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57142 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753352AbcBPDWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 22:22:05 -0500
In-Reply-To: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch drops several checks that we dropped from ixgbe some ago.  It
should not be possible for us to be called with either of the conditional
statements returning true so we can just drop them from the hot-path.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 7366d4f..bb5be40 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5193,16 +5193,6 @@ static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-	if (test_bit(__IGB_DOWN, &adapter->state)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
-	if (skb->len <= 0) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	/* The minimum packet size with TCTL.PSP set is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
 	 */
-- 
2.5.0
