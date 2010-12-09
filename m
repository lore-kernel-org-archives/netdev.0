From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] inet6: Remove redundant unlikely()
Date: Thu,  9 Dec 2010 15:37:48 +0100
Message-ID: <1291905468-32174-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:61149 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754232Ab0LIOhu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 09:37:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR() already implies unlikely(), so it can be omitted here.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/ipv6/af_inet6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 54e8e42..059a3de 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -810,7 +810,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 	}
 	rcu_read_unlock();
 
-	if (unlikely(IS_ERR(segs)))
+	if (IS_ERR(segs))
 		goto out;
 
 	for (skb = segs; skb; skb = skb->next) {
-- 
1.7.0.4

