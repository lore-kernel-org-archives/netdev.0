From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] nf: make skb_make_writable() return bool
Date: Sat, 31 Jul 2010 14:56:24 +0800
Message-ID: <1280559384-25197-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netfilter.h |    2 +-
 net/netfilter/core.c      |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 89341c3..9dc919b 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -243,7 +243,7 @@ int compat_nf_getsockopt(struct sock *sk, u_int8_t pf, int optval,
 /* Call this before modifying an existing packet: ensures it is
    modifiable and linear to the point you care about (writable_len).
    Returns true or false. */
-extern int skb_make_writable(struct sk_buff *skb, unsigned int writable_len);
+extern bool skb_make_writable(struct sk_buff *skb, unsigned int writable_len);
 
 struct flowi;
 struct nf_queue_entry;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 78b505d..274ab8c 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -189,17 +189,17 @@ next_hook:
 EXPORT_SYMBOL(nf_hook_slow);
 
 
-int skb_make_writable(struct sk_buff *skb, unsigned int writable_len)
+bool skb_make_writable(struct sk_buff *skb, unsigned int writable_len)
 {
 	if (writable_len > skb->len)
-		return 0;
+		return false;
 
 	/* Not exclusive use of packet?  Must copy. */
 	if (!skb_cloned(skb)) {
 		if (writable_len <= skb_headlen(skb))
-			return 1;
+			return true;
 	} else if (skb_clone_writable(skb, writable_len))
-		return 1;
+		return true;
 
 	if (writable_len <= skb_headlen(skb))
 		writable_len = 0;
