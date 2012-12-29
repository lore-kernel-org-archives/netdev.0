From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] skbuff: make __kmalloc_reserve static
Date: Fri, 28 Dec 2012 20:24:28 -0800
Message-ID: <20121228202428.5aa18a7b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48169 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab2L2EZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 23:25:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse detected case where this local function should be static.
It may even allow some compiler optimizations.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/skbuff.c	2012-12-28 19:46:31.967615872 -0800
+++ b/net/core/skbuff.c	2012-12-28 20:00:33.343165940 -0800
@@ -155,8 +155,9 @@ static void skb_under_panic(struct sk_bu
  */
 #define kmalloc_reserve(size, gfp, node, pfmemalloc) \
 	 __kmalloc_reserve(size, gfp, node, _RET_IP_, pfmemalloc)
-void *__kmalloc_reserve(size_t size, gfp_t flags, int node, unsigned long ip,
-			 bool *pfmemalloc)
+
+static void *__kmalloc_reserve(size_t size, gfp_t flags, int node,
+			       unsigned long ip, bool *pfmemalloc)
 {
 	void *obj;
 	bool ret_pfmemalloc = false;
