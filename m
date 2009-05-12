From: akpm@linux-foundation.org
Subject: [patch 2/2] sunrpc: align cache_clean work's timer
Date: Tue, 12 May 2009 13:47:34 -0700
Message-ID: <200905122106.n4CL6ovd009895@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, anton@samba.org,
	neilb@suse.de, trond.myklebust@fys.uio.no
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41543 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753057AbZELVKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 17:10:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

Align cache_clean work.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/cache.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/sunrpc/cache.c~sunrpc-align-cache_clean-works-timer net/sunrpc/cache.c
--- a/net/sunrpc/cache.c~sunrpc-align-cache_clean-works-timer
+++ a/net/sunrpc/cache.c
@@ -488,7 +488,7 @@ static void do_cache_clean(struct work_s
 {
 	int delay = 5;
 	if (cache_clean() == -1)
-		delay = 30*HZ;
+		delay = round_jiffies_relative(30*HZ);
 
 	if (list_empty(&cache_list))
 		delay = 0;
_
