From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: add kerneldoc to skb_copy_bits()
Date: Sat, 30 Jul 2011 06:37:31 +0200
Message-ID: <1312000651.2873.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65428 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab1G3Ehk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2011 00:37:40 -0400
Received: by wyg8 with SMTP id 8so561647wyg.19
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 21:37:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since skb_copy_bits() is called from assembly, add a fat comment to make
clear we should think twice before changing its prototype.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2beda82..d6c2958 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1369,8 +1369,21 @@ pull_pages:
 }
 EXPORT_SYMBOL(__pskb_pull_tail);
 
-/* Copy some data bits from skb to kernel buffer. */
-
+/**
+ *	skb_copy_bits - copy bits from skb to kernel buffer
+ *	@skb: source skb
+ *	@offset: offset in source
+ *	@to: destination buffer
+ *	@len: number of bytes to copy
+ *
+ *	Copy the specified number of bytes from the source skb to the
+ *	destination buffer.
+ *
+ *	CAUTION ! :
+ *		If its prototype is ever changed, 
+ *		check arch/{*}/net/{*}.S files,
+ *		since it is called from BPF assembly code.
+ */
 int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
 {
 	int start = skb_headlen(skb);


