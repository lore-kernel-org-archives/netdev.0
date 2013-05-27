From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Mon, 27 May 2013 15:18:14 -0300
Message-ID: <20130527181813.GB6509@optiplex.redhat.com>
References: <1369601101-23057-1-git-send-email-atomlin@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	riel@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: atomlin@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369601101-23057-1-git-send-email-atomlin@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 26, 2013 at 09:45:01PM +0100, atomlin@redhat.com wrote:
> From: Aaron Tomlin <atomlin@redhat.com>
> 
> Since v1:
>  - Removed unnecessary parentheses (sergei.shtylyov)
> 
> ---8<---
> 
> Failed GFP_ATOMIC allocations by the network stack result in dropped
> packets, which will be received on a subsequent retransmit, and an
> unnecessary, noisy warning with a kernel backtrace.
> 
> These warnings are harmless, but they still cause users to panic and
> file bug reports over dropped packets. It would be better to hide the
> failed allocation warnings and backtraces, and let retransmits handle
> dropped packets quietly.
> 
> Signed-off-by: Aaron Tomlin <atomlin@redhat.com>
> ---

Acked-by: Rafael Aquini <aquini@redhat.com>


>  net/core/skbuff.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index af9185d..84aa870 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -236,7 +236,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>  		? skbuff_fclone_cache : skbuff_head_cache;
>  
>  	if (sk_memalloc_socks() && (flags & SKB_ALLOC_RX))
> -		gfp_mask |= __GFP_MEMALLOC;
> +		gfp_mask |= __GFP_MEMALLOC | __GFP_NOWARN;
>  
>  	/* Get the HEAD */
>  	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
> -- 
> 1.8.1.4
> 
