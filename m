From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib: use __fls() on non null argument
Date: Tue, 07 Aug 2012 15:30:53 +0200
Message-ID: <1344346253.28967.93.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62536 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab2HGNa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 09:30:58 -0400
Received: by bkwj10 with SMTP id j10so1446437bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 06:30:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__fls(x) is a bit faster than fls(x), granted we know x is non null.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/fib_trie.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f0cdb30..0bb20c4 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1550,7 +1550,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		 * state.directly.
 		 */
 		if (pref_mismatch) {
-			int mp = KEYLENGTH - fls(pref_mismatch);
+			int mp = KEYLENGTH - __fls(pref_mismatch);
 
 			if (tkey_extract_bits(cn->key, mp, cn->pos - mp) != 0)
 				goto backtrace;
