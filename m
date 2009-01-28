From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4]: net: If SKB has attached socket, use socket's hash
 for TX queue selection.
Date: Tue, 27 Jan 2009 16:40:31 -0800 (PST)
Message-ID: <20090127.164031.28244223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43821
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbZA1Akd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:40:33 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id AC1A535C005
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 16:40:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b21ad0b..cb8caa9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1729,6 +1729,13 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 		goto out;
 	}
 
+	if (skb->sk && skb->sk->sk_hash) {
+		u32 val = skb->sk->sk_hash;
+
+		hash = jhash_1word(val, simple_tx_hashrnd);
+		goto out;
+	}
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		if (!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)))
-- 
1.6.1.15.g159c88

