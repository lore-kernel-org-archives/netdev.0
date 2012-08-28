From: igorm@etf.rs
Subject: [PATCH net-next] net: ipv4: optimize tkey_mismatch
Date: Tue, 28 Aug 2012 10:52:18 +0200
Message-ID: <1346143938-17167-2-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1346143938-17167-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:60412 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab2H1IxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 04:53:11 -0400
In-Reply-To: <1346143938-17167-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Optimize tkey_mismatch function by using __fls function.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/ipv4/fib_trie.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ec45621..b4b126c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -265,14 +265,8 @@ static inline int tkey_sub_equals(t_key a, int offset, int bits, t_key b)
 
 static inline int tkey_mismatch(t_key a, int offset, t_key b)
 {
-	t_key diff = a ^ b;
-	int i = offset;
-
-	if (!diff)
-		return 0;
-	while ((diff << i) >> (KEYLENGTH-1) == 0)
-		i++;
-	return i;
+	t_key diff = (a ^ b) & (~((t_key)0) << offset >> offset);
+	return diff ? (KEYLENGTH - __fls(diff) - 1) : 0;
 }
 
 /*
-- 
1.7.9.5
