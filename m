From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Tue, 20 Mar 2012 08:58:46 +0100
Message-ID: <20120320075846.GF29891@secunet.com>
References: <20120319080220.GA29891@secunet.com>
 <1332213779-19528-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45901 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757249Ab2CTH6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 03:58:50 -0400
Content-Disposition: inline
In-Reply-To: <1332213779-19528-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 20, 2012 at 11:22:59AM +0800, Gao feng wrote:
> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
> In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdrlen)
> the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrlen at last
> This will make fraggap>0 in next "while cycle",and cause the size of skb incorrent
> 
> Fix this by reserve headroom for dst_exthdrlen.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/ipv6/ip6_output.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index d97e071..8d5d204 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1418,6 +1418,8 @@ alloc_new_skb:
>  			skb->csum = 0;
>  			/* reserve for fragmentation */
>  			skb_reserve(skb, hh_len+sizeof(struct frag_hdr));
> +			/* reserve for ipsec header */
> +			skb_reserve(skb, dst_exthdrlen);

Why not 'reserve for fragmentation and ipsec header' instead
of calling skb_reserve() two times?

The rest of the patch looks good.
