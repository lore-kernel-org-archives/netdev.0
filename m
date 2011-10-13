From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ixgbe: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 19:59:41 +0200
Message-ID: <1318528781.2393.59.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55434 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177Ab1JMR7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 13:59:25 -0400
Received: by wwf22 with SMTP id 22so2187390wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 10:59:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ixgbe allocates half a page per skb fragment. We must account
PAGE_SIZE/2 increments on skb->truesize, not the actual frag length.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1519a23..fdb6ae4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1326,7 +1326,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 			skb->len += upper_len;
 			skb->data_len += upper_len;
-			skb->truesize += upper_len;
+			skb->truesize += PAGE_SIZE / 2;
 		}
 
 		i++;
