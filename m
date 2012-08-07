From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] fib: use __fls() on non null argument
Date: Tue, 7 Aug 2012 21:05:04 +0100
Message-ID: <1344369904.2688.53.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344346253.28967.93.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25003 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756061Ab2HGUFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 16:05:07 -0400
In-Reply-To: <1344346253.28967.93.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 15:30 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> __fls(x) is a bit faster than fls(x), granted we know x is non null.

And it doesn't have the +1 bias, so this change is not correct.

Ben.

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/fib_trie.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index f0cdb30..0bb20c4 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1550,7 +1550,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
>  		 * state.directly.
>  		 */
>  		if (pref_mismatch) {
> -			int mp = KEYLENGTH - fls(pref_mismatch);
> +			int mp = KEYLENGTH - __fls(pref_mismatch);
>  
>  			if (tkey_extract_bits(cn->key, mp, cn->pos - mp) != 0)
>  				goto backtrace;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
