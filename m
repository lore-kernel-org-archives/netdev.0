From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 09/17] net: i40e calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:27:58 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260923030.21248@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:56674 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3KZRd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:33:59 -0500
Received: by mail-pd0-f202.google.com with SMTP id g10so841936pdj.5
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:33:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f1f03bc..203048d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1029,7 +1029,8 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 			goto next_desc;
 		}
 
-		skb->rxhash = i40e_rx_hash(rx_ring, rx_desc);
+		skb_set_rxhash(skb, i40e_rx_hash(rx_ring, rx_desc),
+			       RXHASH_TYPE_L3);
 		i40e_rx_checksum(vsi, skb, rx_status, rx_error);
 
 		/* probably a little skewed due to removing CRC */
-- 
1.8.4.1
