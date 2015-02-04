From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] net: core/dev: fix sparse warning
Date: Wed,  4 Feb 2015 12:25:46 +0000
Message-ID: <1423052746-3688-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:
net/core/dev.c: In function 'validate_xmit_skb_list':
net/core/dev.c:2720: warning: 'tail' may be used uninitialized in this function

Although its a false positive, as head is assigned to NULL in the
beginning, due which later in the loop tail is assigned to skb->prev.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8ce0d1a..c736467 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2717,7 +2717,7 @@ out_null:
 
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sk_buff *next, *head = NULL, *tail;
+	struct sk_buff *next, *head = NULL, *tail = NULL;
 
 	for (; skb != NULL; skb = next) {
 		next = skb->next;
-- 
1.9.1
