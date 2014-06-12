From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/4] udp: call __skb_checksum_complete when doing full
 checksum
Date: Thu, 12 Jun 2014 16:04:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406121553370.29725@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:33497 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaFLXED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 19:04:03 -0400
Received: by mail-yk0-f201.google.com with SMTP id 9so105237ykp.2
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 16:04:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __udp_lib_checksum_complete check if checksum is being done over all
the data (len is equal to skb->len) and if it is call
__skb_checksum_complete instead of __skb_checksum_complete_head. This
allows checksum to be saved in checksum complete.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/udp.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 2ecfc6e..68a1fef 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -111,7 +111,9 @@ struct sk_buff;
  */
 static inline __sum16 __udp_lib_checksum_complete(struct sk_buff *skb)
 {
-	return __skb_checksum_complete_head(skb, UDP_SKB_CB(skb)->cscov);
+	return (UDP_SKB_CB(skb)->cscov == skb->len ?
+		__skb_checksum_complete(skb) :
+		__skb_checksum_complete_head(skb, UDP_SKB_CB(skb)->cscov));
 }
 
 static inline int udp_lib_checksum_complete(struct sk_buff *skb)
-- 
2.0.0.526.g5318336
