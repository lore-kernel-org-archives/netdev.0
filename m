From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 6/42] decnet: Fix set-but-unused variable.
Date: Mon, 18 Apr 2011 03:12:09 +0100
Message-ID: <1303092729.5282.1005.camel@localhost>
References: <20110417.173250.183050174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13743 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1DRCMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 22:12:13 -0400
In-Reply-To: <20110417.173250.183050174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-17 at 17:32 -0700, David Miller wrote:
> "next" in dn_rebuild_zone() is set but not actually used,
> kill it off.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/decnet/dn_table.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
> index 99d8d3a..d8ea583 100644
> --- a/net/decnet/dn_table.c
> +++ b/net/decnet/dn_table.c
> @@ -124,11 +124,10 @@ static inline void dn_rebuild_zone(struct dn_zone *dz,
>  				   int old_divisor)
>  {
>  	int i;
> -	struct dn_fib_node *f, **fp, *next;
> +	struct dn_fib_node *f, **fp;
>  
>  	for(i = 0; i < old_divisor; i++) {
>  		for(f = old_ht[i]; f; f = f->fn_next) {
> -			next = f->fn_next;
>  			for(fp = dn_chain_p(f->fn_key, dz);
>  				*fp && dn_key_leq((*fp)->fn_key, f->fn_key);
>  				fp = &(*fp)->fn_next)

This function is rebuilding a hash table after the number of buckets is
changed.  After moving each element into a new bucket, it needs to carry
on iterating over the old bucket.  Therefore the 'next' variable is
really needed and the second for-loop should use it: 'f = next', not
'f = f->fn_next'.

Currently this must just leak routes as the table grows, but I suppose
no-one really uses DECnet any more.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

