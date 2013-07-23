From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH] net: fix comment above build_skb()
Date: Tue, 23 Jul 2013 16:39:03 +0100
Message-ID: <1374593943-31642-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4395 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932138Ab3GWPjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jul 2013 11:39:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

build_skb() specifies that the data parameter must come from a kmalloc'd
area, this is only true if frag_size equals 0, because then build_skb()
will use kzsize(data) to figure out the actual data size. Update the
comment to reflect that special condition.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/core/skbuff.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 20e02d2..d3174db 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -309,7 +309,8 @@ EXPORT_SYMBOL(__alloc_skb);
  * @frag_size: size of fragment, or 0 if head was kmalloced
  *
  * Allocate a new &sk_buff. Caller provides space holding head and
- * skb_shared_info. @data must have been allocated by kmalloc()
+ * skb_shared_info. @data must have been allocated by kmalloc() only if
+ * @frag_size is 0.
  * The return is the new skb buffer.
  * On a failure the return is %NULL, and @data is not freed.
  * Notes :
-- 
1.8.1.2
