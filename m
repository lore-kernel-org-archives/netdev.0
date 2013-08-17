From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] batman-adv: properly end seq_read session
Date: Sat, 17 Aug 2013 12:34:54 +0200
Message-ID: <1376735694-676-2-git-send-email-ordex@autistici.org>
References: <1376735694-676-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:52136 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633Ab3HQKoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 06:44:11 -0400
In-Reply-To: <1376735694-676-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A missing skb_abort_seq_read() has to be added in order to
properly close the seq_read session initiated with
skb_prepare_seq_read().

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 08125f3..51aafd6 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -473,6 +473,7 @@ __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr)
 		crc = crc32c(crc, data, len);
 		consumed += len;
 	}
+	skb_abort_seq_read(&st);
 
 	return htonl(crc);
 }
-- 
1.8.1.5
