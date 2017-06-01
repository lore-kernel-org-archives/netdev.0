From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove unnecessary skb_reset_tail_pointer()
Date: Thu, 01 Jun 2017 14:18:36 -0700
Message-ID: <1496351916.27480.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34844 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751097AbdFAVSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 17:18:38 -0400
Received: by mail-pf0-f193.google.com with SMTP id u26so8990006pfd.2
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 14:18:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__pskb_trim_head() does not need to reset skb tail pointer.

Also change the comments, __pskb_pull_head() does not exist.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 478f75baee31d28b4e3122f7635cd1addf20cb98..e3aab1c1cf78d7b5696fc1438fe54f8ce448c09e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1328,9 +1328,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	return 0;
 }
 
-/* This is similar to __pskb_pull_head() (it will go to core/skbuff.c
- * eventually). The difference is that pulled data not copied, but
- * immediately discarded.
+/* This is similar to __pskb_pull_tail(). The difference is that pulled
+ * data is not copied, but immediately discarded.
  */
 static int __pskb_trim_head(struct sk_buff *skb, int len)
 {
@@ -1365,7 +1364,6 @@ static int __pskb_trim_head(struct sk_buff *skb, int len)
 	}
 	shinfo->nr_frags = k;
 
-	skb_reset_tail_pointer(skb);
 	skb->data_len -= len;
 	skb->len = skb->data_len;
 	return len;
