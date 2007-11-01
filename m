From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Thu, 1 Nov 2007 13:15:30 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711011313060.16864@kivilampi-30.cs.helsinki.fi>
References: <4729A774.9030409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59940 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190AbXKALPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 07:15:32 -0400
In-Reply-To: <4729A774.9030409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Nov 2007, Eric Dumazet wrote:

> @@ -134,6 +156,13 @@ static inline struct inet_ehash_bucket *inet_ehash_bucket(
>  	return &hashinfo->ehash[hash & (hashinfo->ehash_size - 1)];
>  }
>  
> +static inline rwlock_t *inet_ehash_lockp(
> +	struct inet_hashinfo *hashinfo,

...These two fit to 80 columns.

> +	unsigned int hash)
> +{
> +	return &hashinfo->ehash_locks[hash & (EHASH_LOCK_SZ - 1)];
> +}
> +
>  extern struct inet_bind_bucket *
>  		    inet_bind_bucket_create(struct kmem_cache *cachep,
>  					    struct inet_bind_hashbucket *head,

-- 
 i.

