From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] netfilter: udp: Only get 8 bytes header in
 udp_pkt_to_tuple to keep consistent with tcp_pkt_to_tuple and comments
Date: Thu, 21 Jul 2016 11:10:27 +0200
Message-ID: <20160721091027.GE9123@breakpoint.cc>
References: <1469089774-21818-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57100 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751908AbcGUJKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 05:10:37 -0400
Content-Disposition: inline
In-Reply-To: <1469089774-21818-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fgao@ikuai8.com <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  net/netfilter/nf_conntrack_proto_udp.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
> index 4fd0405..a886a8a 100644
> --- a/net/netfilter/nf_conntrack_proto_udp.c
> +++ b/net/netfilter/nf_conntrack_proto_udp.c
> @@ -45,7 +45,7 @@ static bool udp_pkt_to_tuple(const struct sk_buff *skb,
>  	struct udphdr _hdr;
>  
>  	/* Actually only need first 8 bytes. */
> -	hp = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
> +	hp = skb_header_pointer(skb, dataoff, 8, &_hdr);

This comment is a bit misleading; sizeof(udphdr) is 8 bytes so
this patch has no effect.
