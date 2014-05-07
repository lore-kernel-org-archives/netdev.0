From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/7] icmp: Call skb_checksum_simple_validate
Date: Wed, 7 May 2014 16:52:21 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071643110.944@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:54933 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbaEGXwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:52:22 -0400
Received: by mail-qa0-f74.google.com with SMTP id ih12so271473qab.3
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:52:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_checksum_simple_validate to verify checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/icmp.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 0134663..fe52666 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -908,16 +908,8 @@ int icmp_rcv(struct sk_buff *skb)
 
 	ICMP_INC_STATS_BH(net, ICMP_MIB_INMSGS);
 
-	switch (skb->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		if (!csum_fold(skb->csum))
-			break;
-		/* fall through */
-	case CHECKSUM_NONE:
-		skb->csum = 0;
-		if (__skb_checksum_complete(skb))
-			goto csum_error;
-	}
+	if (skb_checksum_simple_validate(skb))
+		goto csum_error;
 
 	if (!pskb_pull(skb, sizeof(*icmph)))
 		goto error;
-- 
1.9.1.423.g4596e3a
