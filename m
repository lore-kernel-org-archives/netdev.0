From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 2/2] ipv6: l2tp: fix a potential issue in l2tp_ip6_recv
Date: Sun,  3 Apr 2016 22:09:24 +0800
Message-ID: <1459692564-3998-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1459692564-3998-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459692564-3998-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pskb_may_pull() can change skb->data, so we have to load ptr/optr at the
right place.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/l2tp/l2tp_ip6.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 6b54ff3..cd47990 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -136,12 +136,11 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 	struct l2tp_tunnel *tunnel = NULL;
 	int length;
 
-	/* Point to L2TP header */
-	optr = ptr = skb->data;
-
 	if (!pskb_may_pull(skb, 4))
 		goto discard;
 
+	/* Point to L2TP header */
+	optr = ptr = skb->data;
 	session_id = ntohl(*((__be32 *) ptr));
 	ptr += 4;
 
@@ -169,6 +168,9 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 		if (!pskb_may_pull(skb, length))
 			goto discard;
 
+		/* Point to L2TP header */
+		optr = ptr = skb->data;
+		ptr += 4;
 		pr_debug("%s: ip recv\n", tunnel->name);
 		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, ptr, length);
 	}
-- 
1.8.3.1
