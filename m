From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 10:51:25 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:60651 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407AbbCQKwj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 06:52:39 -0400
In-Reply-To: <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Sent: 15 March 2015 10:44
> Keeping both size and shift is silly.  We only need one.
...
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -162,7 +162,6 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
>  		return NULL;
> 
>  	tbl->size = nbuckets;
> -	tbl->shift = ilog2(nbuckets);
> 
>  	if (alloc_bucket_locks(ht, tbl) < 0) {
>  		bucket_table_free(tbl);
> @@ -189,7 +188,7 @@ static bool rht_grow_above_75(const struct rhashtable *ht,
>  {
>  	/* Expand table when exceeding 75% load */
>  	return atomic_read(&ht->nelems) > (tbl->size / 4 * 3) &&
> -	       (!ht->p.max_shift || tbl->shift < ht->p.max_shift);
> +	       (!ht->p.max_shift || tbl->size < (1 << ht->p.max_shift));

Looks like you could pre-calculate the 'grow_at' size.
The test above would then be:
	return atomic_read(&ht->nelems > tbl->grow_at_size);

Similarly for the shrink.

	David
