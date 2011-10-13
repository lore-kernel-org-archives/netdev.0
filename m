From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] e1000: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 19:53:42 +0200
Message-ID: <1318528422.2393.55.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58038 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab1JMRxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 13:53:24 -0400
Received: by mail-ww0-f44.google.com with SMTP id 22so2177730wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 10:53:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000 allocates a full page per skb fragment. We must account PAGE_SIZE
increments on skb->truesize, not the actual frag length.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index a42421f..7b54d72 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3737,7 +3737,7 @@ static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
 	bi->page = NULL;
 	skb->len += length;
 	skb->data_len += length;
-	skb->truesize += length;
+	skb->truesize += PAGE_SIZE;
 }
 
 /**
