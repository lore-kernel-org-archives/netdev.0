From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v2 2/2] amd-xgbe: Associate Tx SKB with proper ring
 descriptor
Date: Wed, 3 Dec 2014 08:36:42 -0600
Message-ID: <20141203143642.25084.29478.stgit@tlendack-t1.amdoffice.net>
References: <20141203143630.25084.91079.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0102.outbound.protection.outlook.com ([157.56.111.102]:54496
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752848AbaLCOgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 09:36:47 -0500
In-Reply-To: <20141203143630.25084.91079.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SKB for a Tx packet is associated with an xgbe_ring_data structure
in the xgbe_map_tx_skb function.  However, it is being saved in the
structure after the last structure used when the SKB is mapped.  Use
the last used structure to save the SKB value.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 43b7d2e..b15551b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -480,7 +480,11 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 		}
 	}
 
-	/* Save the skb address in the last entry */
+	/* Save the skb address in the last entry. We always have some data
+	 * that has been mapped so rdata is always advanced past the last
+	 * piece of mapped data - use the entry pointed to by cur_index - 1.
+	 */
+	rdata = XGBE_GET_DESC_DATA(ring, cur_index - 1);
 	rdata->skb = skb;
 
 	/* Save the number of descriptor entries used */
