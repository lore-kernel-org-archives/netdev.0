From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] e1000e: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 20:03:36 +0200
Message-ID: <1318529016.2393.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33992 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207Ab1JMSD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 14:03:27 -0400
Received: by wyg34 with SMTP id 34so2154157wyg.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 11:03:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000e allocates a page per skb fragment. We must account
PAGE_SIZE increments on skb->truesize, not the actual frag length.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 78c5d21..035ce73 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1300,7 +1300,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			ps_page->page = NULL;
 			skb->len += length;
 			skb->data_len += length;
-			skb->truesize += length;
+			skb->truesize += PAGE_SIZE;
 		}
 
 		/* strip the ethernet crc, problem is we're using pages now so
@@ -1360,7 +1360,7 @@ static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
 	bi->page = NULL;
 	skb->len += length;
 	skb->data_len += length;
-	skb->truesize += length;
+	skb->truesize += PAGE_SIZE;
 }
 
 /**
