From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v4 net 1/3] net: dst: provide accessor function to
 dst->xfrm
Date: Wed, 16 Oct 2013 09:31:29 -0400
Message-ID: <20131016133129.GA10623@neilslaptop.think-freely.org>
References: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
 <1381888891-31186-2-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	fan.du@windriver.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56641 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934252Ab3JPNbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 09:31:41 -0400
Content-Disposition: inline
In-Reply-To: <1381888891-31186-2-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 15, 2013 at 10:01:29PM -0400, Vlad Yasevich wrote:
> dst->xfrm is conditionally defined.  Provide accessor funtion that
> is always available.
> 
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> ---
>  include/net/dst.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 3bc4865..3c4c944 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -479,10 +479,22 @@ static inline struct dst_entry *xfrm_lookup(struct net *net,
>  {
>  	return dst_orig;
>  } 
> +
> +static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
> +{
> +	return NULL;
> +}
> +
>  #else
>  extern struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
>  				     const struct flowi *fl, struct sock *sk,
>  				     int flags);
> +
> +/* skb attached with this dst needs transformation if dst->xfrm is valid */
> +static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
> +{
> +	return dst->xfrm;
> +}
>  #endif
>  
>  #endif /* _NET_DST_H */
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
