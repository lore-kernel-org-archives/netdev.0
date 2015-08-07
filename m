From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 28/31] net/xfrm: use kmemdup rather than duplicating its
 implementation
Date: Fri, 07 Aug 2015 09:59:34 +0200
Message-ID: <1438934377-4922-29-git-send-email-a.hajda@samsung.com>
References: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch was generated using fixed coccinelle semantic patch
scripts/coccinelle/api/memdup.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2014320

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
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
