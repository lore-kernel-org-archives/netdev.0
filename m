From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/15]: bluetooth: Kill skb_frags_no(), unused.
Date: Tue, 09 Jun 2009 05:01:49 -0700 (PDT)
Message-ID: <20090609.050149.48753449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756130AbZFIMBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:01:47 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6AC20C8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:01:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Furthermore, it twiddles with the details of SKB list handling
directly, which we're trying to eliminate.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/bluetooth/bluetooth.h |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 3ad5390..144d1d5 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -171,15 +171,6 @@ static inline struct sk_buff *bt_skb_send_alloc(struct sock *sk, unsigned long l
 	return skb;
 }
 
-static inline int skb_frags_no(struct sk_buff *skb)
-{
-	register struct sk_buff *frag = skb_shinfo(skb)->frag_list;
-	register int n = 1;
-
-	for (; frag; frag=frag->next, n++);
-	return n;
-}
-
 int bt_err(__u16 code);
 
 extern int hci_sock_init(void);
-- 
1.6.3.2

