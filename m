From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv4: fix checksum annotation in udp4_csum_init
Date: Sun, 12 Jun 2016 12:02:46 +0200
Message-ID: <1465725766-14474-1-git-send-email-hannes@stressinduktion.org>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:54413 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750827AbcFLKC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 06:02:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Tom Herbert <tom@herbertland.com>
Fixes: 4068579e1e098fa ("net: Implmement RFC 6936 (zero RX csums for UDP/IPv6")
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/udp.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0ff31d97d48586..ba0d8b8b76900a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1755,8 +1755,11 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 			return err;
 	}
 
-	return skb_checksum_init_zero_check(skb, proto, uh->check,
-					    inet_compute_pseudo);
+	/* Note, we are only interested in != 0 or == 0, thus the
+	 * force to int.
+	 */
+	return (__force int)skb_checksum_init_zero_check(skb, proto, uh->check,
+							 inet_compute_pseudo);
 }
 
 /*
-- 
2.5.5
