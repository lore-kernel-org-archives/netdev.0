From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] net: packet: use reciprocal_divide in fanout_demux_hash
Date: Wed, 28 Aug 2013 22:13:10 +0200
Message-ID: <1377720791-15844-3-git-send-email-dborkman@redhat.com>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755168Ab3H1UNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 16:13:18 -0400
In-Reply-To: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of hard-coding reciprocal_divide function, use the inline
function from reciprocal_div.h.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/af_packet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 91596f5..130e2ea 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1135,7 +1135,7 @@ static unsigned int fanout_demux_hash(struct packet_fanout *f,
 				      struct sk_buff *skb,
 				      unsigned int num)
 {
-	return (((u64)skb->rxhash) * num) >> 32;
+	return reciprocal_divide(skb->rxhash, num);
 }
 
 static unsigned int fanout_demux_lb(struct packet_fanout *f,
-- 
1.7.11.7
