From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] ipv4: remove the unnecessary codes in fib_info_hash_move
Date: Thu, 30 Apr 2015 17:25:12 +0800
Message-ID: <1430385912-21987-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39593 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbbD3JZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 05:25:14 -0400
Received: from localhost (lirq-optiplex-780.corp.ad.wrs.com [128.224.162.142])
	by mail.windriver.com (8.14.9/8.14.9) with ESMTP id t3U9PDnC023217
	for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 02:25:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The whole hlist will be moved, so not need to call hlist_del before
add the hlist_node to other hlist_head.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/fib_semantics.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 8d695b6..28ec3c1 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -713,8 +713,6 @@ static void fib_info_hash_move(struct hlist_head *new_info_hash,
 			struct hlist_head *dest;
 			unsigned int new_hash;
 
-			hlist_del(&fi->fib_hash);
-
 			new_hash = fib_info_hashfn(fi);
 			dest = &new_info_hash[new_hash];
 			hlist_add_head(&fi->fib_hash, dest);
@@ -731,8 +729,6 @@ static void fib_info_hash_move(struct hlist_head *new_info_hash,
 			struct hlist_head *ldest;
 			unsigned int new_hash;
 
-			hlist_del(&fi->fib_lhash);
-
 			new_hash = fib_laddr_hashfn(fi->fib_prefsrc);
 			ldest = &new_laddrhash[new_hash];
 			hlist_add_head(&fi->fib_lhash, ldest);
-- 
2.1.0
