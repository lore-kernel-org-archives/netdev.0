From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH][CIPSO]: Relax too much careful cipso hash function.
Date: Tue, 13 May 2008 14:34:44 -0400
Message-ID: <200805131434.44463.paul.moore@hp.com>
References: <4829937D.9070409@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:13323 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbYEMSet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 14:34:49 -0400
In-Reply-To: <4829937D.9070409@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 May 2008 9:11:25 am Pavel Emelyanov wrote:
> The cipso_v4_cache is allocated to contain CIPSO_V4_CACHE_BUCKETS
> buckets. The CIPSO_V4_CACHE_BUCKETS = 1 << CIPSO_V4_CACHE_BUCKETBITS,
> where CIPSO_V4_CACHE_BUCKETBITS = 7.
>
> The bucket-selection function for this hash is calculated like this:
>
>   bkt = hash & (CIPSO_V4_CACHE_BUCKETBITS - 1);
>                                      ^^^
>
> i.e. picking only 4 buckets of possible 128 :)
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks Pavel, braino on my part.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>  net/ipv4/cipso_ipv4.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> index 05afb57..2c0e457 100644
> --- a/net/ipv4/cipso_ipv4.c
> +++ b/net/ipv4/cipso_ipv4.c
> @@ -338,7 +338,7 @@ static int cipso_v4_cache_check(const unsigned
> char *key, return -ENOENT;
>
>  	hash = cipso_v4_map_cache_hash(key, key_len);
> -	bkt = hash & (CIPSO_V4_CACHE_BUCKETBITS - 1);
> +	bkt = hash & (CIPSO_V4_CACHE_BUCKETS - 1);
>  	spin_lock_bh(&cipso_v4_cache[bkt].lock);
>  	list_for_each_entry(entry, &cipso_v4_cache[bkt].list, list) {
>  		if (entry->hash == hash &&
> @@ -417,7 +417,7 @@ int cipso_v4_cache_add(const struct sk_buff *skb,
>  	atomic_inc(&secattr->cache->refcount);
>  	entry->lsm_data = secattr->cache;
>
> -	bkt = entry->hash & (CIPSO_V4_CACHE_BUCKETBITS - 1);
> +	bkt = entry->hash & (CIPSO_V4_CACHE_BUCKETS - 1);
>  	spin_lock_bh(&cipso_v4_cache[bkt].lock);
>  	if (cipso_v4_cache[bkt].size < cipso_v4_cache_bucketsize) {
>  		list_add(&entry->list, &cipso_v4_cache[bkt].list);



-- 
paul moore
linux @ hp
