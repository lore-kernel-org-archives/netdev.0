From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] netfilter: Correct calculation using skb->tail and
 skb-network_header
Date: Fri, 31 May 2013 11:37:11 +0900
Message-ID: <20130531023710.GA32176@verge.net.au>
References: <1369958746-26318-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Chen Gang <gang.chen@asianux.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369958746-26318-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 31, 2013 at 09:05:46AM +0900, Simon Horman wrote:
> This corrects an regression introduced by "net: Use 16bits for *_headers
> fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
> that case skb->tail will be a pointer whereas skb->network_header
> will be an offset from head. This is corrected by using wrappers that
> ensure that calculations are always made using pointers.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Reported-by: Chen Gang <gang.chen@asianux.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I forgot to note in the subject that this patch is for net-next.
I will re-post accordingly.

> 
> --
> v2
> * Use skb_tail_pointer() to ensure the tail portion of the calculation is
>   always a pointer - it is not if NET_SKBUFF_DATA_USES_OFFSET is not set.
> ---
>  net/netfilter/nf_nat_helper.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
> index 5fea563..85e20a9 100644
> --- a/net/netfilter/nf_nat_helper.c
> +++ b/net/netfilter/nf_nat_helper.c
> @@ -104,7 +104,7 @@ static void mangle_contents(struct sk_buff *skb,
>  	/* move post-replacement */
>  	memmove(data + match_offset + rep_len,
>  		data + match_offset + match_len,
> -		skb->tail - (skb->network_header + dataoff +
> +		skb_tail_pointer(skb) - (skb_network_header(skb) + dataoff +
>  			     match_offset + match_len));
>  
>  	/* insert data from buffer */
> -- 
> 1.7.10.4
> 
