From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] net/xfrm: use kmemdup rather than duplicating its implementation
Date: Mon, 17 Aug 2015 21:58:19 +0200
Message-ID: <1439841501-20990-3-git-send-email-steffen.klassert@secunet.com>
References: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55652 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751409AbbHQT6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 15:58:34 -0400
In-Reply-To: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrzej Hajda <a.hajda@samsung.com>

The patch was generated using fixed coccinelle semantic patch
scripts/coccinelle/api/memdup.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2014320

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 0cebf1f..a8de9e3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -925,12 +925,10 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 			return err;
 
 		if (attrs[XFRMA_ADDRESS_FILTER]) {
-			filter = kmalloc(sizeof(*filter), GFP_KERNEL);
+			filter = kmemdup(nla_data(attrs[XFRMA_ADDRESS_FILTER]),
+					 sizeof(*filter), GFP_KERNEL);
 			if (filter == NULL)
 				return -ENOMEM;
-
-			memcpy(filter, nla_data(attrs[XFRMA_ADDRESS_FILTER]),
-			       sizeof(*filter));
 		}
 
 		if (attrs[XFRMA_PROTO])
-- 
1.9.1
