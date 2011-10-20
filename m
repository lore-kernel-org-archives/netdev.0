From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igbvf: fix truesize underestimation
Date: Thu, 20 Oct 2011 21:22:18 +0200
Message-ID: <1319138538.2854.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56045 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab1JTTWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 15:22:23 -0400
Received: by wyg36 with SMTP id 36so3240223wyg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 12:22:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

igbvf allocates half a page per skb fragment. We must account
PAGE_SIZE/2 increments on skb->truesize, not the actual frag length.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 1bd9abd..db29817 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -312,7 +312,7 @@ static bool igbvf_clean_rx_irq(struct igbvf_adapter *adapter,
 
 			skb->len += length;
 			skb->data_len += length;
-			skb->truesize += length;
+			skb->truesize += PAGE_SIZE / 2;
 		}
 send_up:
 		i++;
