From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 4/7] tcp: Call gso_make_checksum
Date: Wed, 4 Jun 2014 17:20:09 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406041706280.14799@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:59063 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167AbaFEAUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 20:20:11 -0400
Received: by mail-yh0-f74.google.com with SMTP id 29so74529yhl.1
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 17:20:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call common gso_make_checksum when calculating checksum for a
TCP GSO segment.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/tcp_offload.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index b92b817..d8de7b9 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -97,9 +97,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 		th->check = newcheck;
 
 		if (skb->ip_summed != CHECKSUM_PARTIAL)
-			th->check =
-			     csum_fold(csum_partial(skb_transport_header(skb),
-						    thlen, skb->csum));
+			th->check = gso_make_checksum(skb, ~th->check);
 
 		seq += mss;
 		if (copy_destructor) {
@@ -133,8 +131,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
 				(__force u32)delta));
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		th->check = csum_fold(csum_partial(skb_transport_header(skb),
-						   thlen, skb->csum));
+		th->check = gso_make_checksum(skb, ~th->check);
 out:
 	return segs;
 }
-- 
2.0.0.526.g5318336
