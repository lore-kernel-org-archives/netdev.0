From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fib: use __fls() on non null argument
Date: Tue, 07 Aug 2012 22:45:47 +0200
Message-ID: <1344372347.28967.154.camel@edumazet-glaptop>
References: <1344346253.28967.93.camel@edumazet-glaptop>
	 <1344369904.2688.53.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34634 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab2HGUpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 16:45:52 -0400
Received: by bkwj10 with SMTP id j10so14706bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 13:45:51 -0700 (PDT)
In-Reply-To: <1344369904.2688.53.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Tue, 2012-08-07 at 21:05 +0100, Ben Hutchings wrote:
> On Tue, 2012-08-07 at 15:30 +0200, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > __fls(x) is a bit faster than fls(x), granted we know x is non null.
> 
> And it doesn't have the +1 bias, so this change is not correct.

Good catch, I wonder why my routing was still working...

[PATCH v2 net-next] fib: use __fls() on non null argument

__fls(x) is a bit faster than fls(x), granted we know x is non null.

As Ben Hutchings pointed out, fls(x) = __fls(x) + 1

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
 net/ipv4/fib_trie.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f0cdb30..f84a0e9 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1550,7 +1550,8 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		 * state.directly.
 		 */
 		if (pref_mismatch) {
-			int mp = KEYLENGTH - fls(pref_mismatch);
+			/* fls(x) = __fls(x) + 1 */
+			int mp = KEYLENGTH - __fls(pref_mismatch) - 1;
 
 			if (tkey_extract_bits(cn->key, mp, cn->pos - mp) != 0)
 				goto backtrace;
