From: Jitendra Kumar Khasdev <jkhasdev@gmail.com>
Subject: [PATCH] staging: net: core: skbuff.c: Added do-while pair for complex macros
Date: Thu, 26 Nov 2015 22:06:03 +0530
Message-ID: <1448555763-5088-1-git-send-email-jitendra.khasdev@hotwaxsystems.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jitendra Kumar Khasdev <jitendra.khasdev@hotwaxsystems.com>,
	Jitendra Kumar Khasdev <jkhasdev@gmail.com>
To: davem@davemloft.net, edumazet@google.com,
	alexander.h.duyck@redhat.com, linus.luessing@c0d3.bluen,
	hannes@stressinduktion.org, willemb@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to file skbuff.c that fixes up following error,
reported by checkpatch.pl tool,

1. ERROR: Macros with multiple statements should be enclosed
   in a do - while loop.

Signed-off-by: Jitendra Kumar Khasdev <jkhasdev@gmail.com>
---
 net/core/skbuff.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index aa41e6d..4d31228 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -748,11 +748,13 @@ void consume_skb(struct sk_buff *skb)
 EXPORT_SYMBOL(consume_skb);
 
 /* Make sure a field is enclosed inside headers_start/headers_end section */
-#define CHECK_SKB_FIELD(field) \
-	BUILD_BUG_ON(offsetof(struct sk_buff, field) <		\
-		     offsetof(struct sk_buff, headers_start));	\
-	BUILD_BUG_ON(offsetof(struct sk_buff, field) >		\
-		     offsetof(struct sk_buff, headers_end));	\
+#define CHECK_SKB_FIELD(field)						\
+	do {								\
+		BUILD_BUG_ON(offsetof(struct sk_buff, field) <		\
+			offsetof(struct sk_buff, headers_start));	\
+		BUILD_BUG_ON(offsetof(struct sk_buff, field) >		\
+			offsetof(struct sk_buff, headers_end));		\
+	} while (0)							\
 
 static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
-- 
1.9.1
