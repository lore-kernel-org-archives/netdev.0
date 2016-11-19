From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: make struct napi_alloc_cache::skb_count unsigned int
Date: Sat, 19 Nov 2016 03:47:56 +0300
Message-ID: <20161119004756.GC1200@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35403 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbcKRWsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 17:48:06 -0500
Received: by mail-wm0-f65.google.com with SMTP id a20so10742137wme.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 14:48:05 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

size_t is way too much for an integer not exceeding 64.

Space savings: 10 bytes!

	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-10 (-10)
	function                                     old     new   delta
	napi_consume_skb                             165     163      -2
	__kfree_skb_flush                             56      53      -3
	__kfree_skb_defer                             97      92      -5
	Total: Before=154865639, After=154865629, chg -0.00%

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/skbuff.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -354,7 +354,7 @@ EXPORT_SYMBOL(build_skb);
 
 struct napi_alloc_cache {
 	struct page_frag_cache page;
-	size_t skb_count;
+	unsigned int skb_count;
 	void *skb_cache[NAPI_SKB_CACHE_SIZE];
 };
 
