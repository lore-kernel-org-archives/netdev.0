From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH] skb_put: remove not needed check for skb linearity
Date: Tue, 30 Mar 2010 16:01:31 +0300
Message-ID: <20100330130131.8432.43671.stgit@pauliusz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:56288 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab0C3NBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 09:01:35 -0400
Received: by bwz1 with SMTP id 1so4342526bwz.21
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 06:01:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is safe to call skb_put() on packets containing fragments.

Actually I have a case where I allocate packet header with some
extra headroom and then I dynamically add data as frag_list. After
adding frags I have to add more data to header and skb_put()
just BUG's on me :)

And we will save couple instructions for CPU.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
---

 include/linux/skbuff.h |    1 -
 net/core/skbuff.c      |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 124f90c..194e9fa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1108,7 +1108,6 @@ extern unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 {
 	unsigned char *tmp = skb_tail_pointer(skb);
-	SKB_LINEAR_ASSERT(skb);
 	skb->tail += len;
 	skb->len  += len;
 	return tmp;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 93c4e06..ea1ca61 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1011,7 +1011,6 @@ EXPORT_SYMBOL(skb_pad);
 unsigned char *skb_put(struct sk_buff *skb, unsigned int len)
 {
 	unsigned char *tmp = skb_tail_pointer(skb);
-	SKB_LINEAR_ASSERT(skb);
 	skb->tail += len;
 	skb->len  += len;
 	if (unlikely(skb->tail > skb->end))

