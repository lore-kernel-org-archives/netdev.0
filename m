From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 17:53:24 -0400 (EDT)
Message-ID: <20141022.175324.351857495227075331.davem@davemloft.net>
References: <5447FDB2.2010906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cdleonard@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932542AbaJVVx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 17:53:26 -0400
In-Reply-To: <5447FDB2.2010906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Crestez Dan Leonard <cdleonard@gmail.com>
Date: Wed, 22 Oct 2014 21:55:46 +0300

>  static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
>  					__be32 daddr, __be32 saddr, int nbytes)
>  {
> -	struct tcp4_pseudohdr *bp;
> +	struct tcp4_pseudohdr bp;
...
> +	sg_init_one(&sg, &bp, sizeof(bp));
> +	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(bp));

As others have mentioned, you cannot do this.

On some architectures the kernel stack comes from vmalloc()
memory too.
