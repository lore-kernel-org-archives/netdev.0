From: Jerry Snitselaar <jerry.snitselaar@oracle.com>
Subject: [PATCH] fib_trie: potential out of bounds access in trie_show_stats()
Date: Mon, 22 Jul 2013 12:01:58 -0700
Message-ID: <1374519718-8299-1-git-send-email-jerry.snitselaar@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17144 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932521Ab3GVTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 15:02:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the <= max condition in the for loop, it will be always go 1
element further than needed. If the condition for the while loop is
never met, then max is MAX_STAT_DEPTH, and for loop will walk off the
end of nodesizes[].

Signed-off-by: Jerry Snitselaar <jerry.snitselaar@oracle.com>
---
 net/ipv4/fib_trie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 49616fe..108a1e9c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2133,7 +2133,7 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 		max--;
 
 	pointers = 0;
-	for (i = 1; i <= max; i++)
+	for (i = 1; i < max; i++)
 		if (stat->nodesizes[i] != 0) {
 			seq_printf(seq, "  %u: %u",  i, stat->nodesizes[i]);
 			pointers += (1<<i) * stat->nodesizes[i];
-- 
1.8.3.2.701.g8c4e4ec
