From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] macvtap: segmented packet is consumed
Date: Fri, 06 May 2016 05:58:21 -0700
Message-ID: <1462539501.13075.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32928 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbcEFM6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 08:58:24 -0400
Received: by mail-pa0-f48.google.com with SMTP id xk12so47812745pac.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 05:58:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If GSO packet is segmented and its segments are properly queued,
we call consume_skb() instead of kfree_skb() to be drop monitor
friendly.

Fixes: 3e4f8b7873709 ("macvtap: Perform GSO on forwarding path.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 95394edd1ed5..9a35aa462314 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -373,7 +373,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 			goto wake_up;
 		}
 
-		kfree_skb(skb);
+		consume_skb(skb);
 		while (segs) {
 			struct sk_buff *nskb = segs->next;
 
