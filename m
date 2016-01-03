From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH next] net/core/dev: Warn on an impossibly short offload frame
Date: Sat,  2 Jan 2016 19:25:13 -0500
Message-ID: <1451780713-4098-1-git-send-email-aconole@bytheb.org>
Cc: Eric Dumazet <edumazet@google.com>,
	Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:35792 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbcACAZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 19:25:36 -0500
Received: by mail-qk0-f174.google.com with SMTP id n135so118307770qka.2
        for <netdev@vger.kernel.org>; Sat, 02 Jan 2016 16:25:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When signaling that a GRO frame is ready to be processed, the network stack
correctly checks length and aborts processing when a frame is less than 14
bytes. However, such a condition is really indicative of a broken driver,
and should be loudly signaled, rather than silently dropped as the case is
today.

Convert the condition to use WARN_ON() to ensure that the stack loudly
complains about such broken drivers.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 914b4a2..8af4e29 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4579,7 +4579,7 @@ static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 	eth = skb_gro_header_fast(skb, 0);
 	if (unlikely(skb_gro_header_hard(skb, hlen))) {
 		eth = skb_gro_header_slow(skb, hlen, 0);
-		if (unlikely(!eth)) {
+		if (WARN_ON(!eth)) {
 			napi_reuse_skb(napi, skb);
 			return NULL;
 		}
-- 
2.6.4
