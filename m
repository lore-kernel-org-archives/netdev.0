From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 9/9] net: increase frag queue hash size and
 cache-line
Date: Thu, 29 Nov 2012 08:55:13 -0800
Message-ID: <1354208113.14302.1855.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161552.17754.86087.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:40239 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab2K2QzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 11:55:17 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so7749791pad.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 08:55:17 -0800 (PST)
In-Reply-To: <20121129161552.17754.86087.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 17:16 +0100, Jesper Dangaard Brouer wrote:
> Increase frag queue hash size and assure cache-line alignment to
> avoid false sharing.  Hash size is set to 256, because I have
> observed 206 frag queues in use at 4x10G with packet size 4416 bytes
> (three fragments).
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> 
>  include/net/inet_frag.h  |    5 ++---
>  net/ipv4/inet_fragment.c |    2 +-
>  2 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index 431f68e..c8ad7e4 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -47,13 +47,12 @@ struct inet_frag_queue {
>  	u16			max_size;
>  };
>  
> -#define INETFRAGS_HASHSZ		64
> -
> +#define INETFRAGS_HASHSZ	256
>  
>  struct inet_frag_bucket {
>  	struct hlist_head	chain;
>  	spinlock_t		chain_lock;
> -};
> +} ____cacheline_aligned_in_smp;
>  

This is a waste of memory.

Most linux powered devices dont care at all about fragments.

Just increase hashsz if you really want, and rely on hash dispersion
to avoid false sharing.

You gave no performance results for this patch anyway.
