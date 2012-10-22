From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: 16 slots in initial fib_info hash table
Date: Mon, 22 Oct 2012 08:12:09 +0200
Message-ID: <1350886329.8609.276.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:61686 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab2JVGMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 02:12:13 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so686925eaa.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 23:12:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A small host typically needs ~10 fib_info structures, so create initial
hash table with 16 slots instead of only one. This removes potential
false sharing and reallocs/rehashes (1->2->4->8->16)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/fib_semantics.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 71b125c..4797a80 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -803,7 +803,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		unsigned int bytes;
 
 		if (!new_size)
-			new_size = 1;
+			new_size = 16;
 		bytes = new_size * sizeof(struct hlist_head *);
 		new_info_hash = fib_info_hash_alloc(bytes);
 		new_laddrhash = fib_info_hash_alloc(bytes);
