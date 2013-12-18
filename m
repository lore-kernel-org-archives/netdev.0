From: Tom Herbert <therbert@google.com>
Subject: [PATCH 07/15] net: i40e calls skb_set_hash
Date: Tue, 17 Dec 2013 23:27:30 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172325550.24389@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:35993 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab3LRH1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:27:31 -0500
Received: by mail-oa0-f74.google.com with SMTP id o6so1460125oag.5
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:27:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 01d0334..2447d1c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1031,7 +1031,8 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 			goto next_desc;
 		}
 
-		skb->rxhash = i40e_rx_hash(rx_ring, rx_desc);
+		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
+			     PKT_HASH_TYPE_L3);
 		i40e_rx_checksum(vsi, skb, rx_status, rx_error);
 
 		/* probably a little skewed due to removing CRC */
-- 
1.8.5.1
