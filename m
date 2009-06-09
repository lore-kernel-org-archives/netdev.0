From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/15]: phonet: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:02:26 -0700 (PDT)
Message-ID: <20090609.050226.265350537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58259
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760057AbZFIMCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3DEFAC8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/phonet/pep-gprs.c |    4 ++--
 net/phonet/pep.c      |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 851f6a3..480839d 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -115,10 +115,10 @@ static int gprs_recv(struct gprs_dev *gp, struct sk_buff *skb)
 		rskb->truesize += rskb->len;
 
 		/* Avoid nested fragments */
-		for (fs = skb_shinfo(skb)->frag_list; fs; fs = fs->next)
+		skb_walk_frags(skb, fs)
 			flen += fs->len;
 		skb->next = skb_shinfo(skb)->frag_list;
-		skb_shinfo(skb)->frag_list = NULL;
+		skb_frag_list_init(skb);
 		skb->len -= flen;
 		skb->data_len -= flen;
 		skb->truesize -= flen;
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 8ad2b53..eef833e 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -940,10 +940,10 @@ int pep_write(struct sock *sk, struct sk_buff *skb)
 	rskb->truesize += rskb->len;
 
 	/* Avoid nested fragments */
-	for (fs = skb_shinfo(skb)->frag_list; fs; fs = fs->next)
+	skb_walk_frags(skb, fs)
 		flen += fs->len;
 	skb->next = skb_shinfo(skb)->frag_list;
-	skb_shinfo(skb)->frag_list = NULL;
+	skb_frag_list_init(skb);
 	skb->len -= flen;
 	skb->data_len -= flen;
 	skb->truesize -= flen;
-- 
1.6.3.2

