From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] NET: Fix ipv6 GSO payload length
Date: Fri, 30 Jun 2006 15:56:47 -0700
Message-ID: <1151708208.3645.2.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:35849 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932125AbWF3Wzi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 18:55:38 -0400
To: davem@davemloft.net, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix ipv6 GSO payload length calculation.

The ipv6 payload length excludes the ipv6 base header length and so
must be subtracted.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 25f8bf8..2d622d1 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -112,7 +112,8 @@ unlock:
 
 	for (skb = segs; skb; skb = skb->next) {
 		ipv6h = skb->nh.ipv6h;
-		ipv6h->payload_len = htons(skb->len - skb->mac_len);
+		ipv6h->payload_len = htons(skb->len - skb->mac_len -
+					   sizeof(*ipv6h));
 	}
 
 out:


