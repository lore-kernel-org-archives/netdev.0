From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] net: Use cached copy of pfmemalloc to avoid
 accessing page
Date: Sun, 10 May 2015 19:18:51 -0400 (EDT)
Message-ID: <20150510.191851.414324528131774160.davem@davemloft.net>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
	<20150507041140.1873.58533.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 eric.dumazet@gmail.com
To: alexander.h.duyck@redhat.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150507041140.1873.58533.stgit@ahduyck-vm-fedora22>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:11:40 -0700

> +	/* use OR instead of assignment to avoid clearing of bits in mask */
> +	if (pfmemalloc)
> +		skb->pfmemalloc = 1;
> +	skb->head_frag = 1;
 ...
> +	/* use OR instead of assignment to avoid clearing of bits in mask */
> +	if (nc->pfmemalloc)
> +		skb->pfmemalloc = 1;
> +	skb->head_frag = 1;

Maybe make these two cases more consistent by either accessing
nc->pfmemalloc or using a local variable in both cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
