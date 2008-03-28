From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/3] [LLC]: bogus llc packet length
Date: Fri, 28 Mar 2008 10:13:17 -0300
Message-ID: <20080328131317.GQ14945@ghostprotocols.net>
References: <1206691175-10905-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Arnaldo Carvalho de Melo <acme@redhat.com>,
	netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbYC1NNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 09:13:20 -0400
Content-Disposition: inline
In-Reply-To: <1206691175-10905-1-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 28, 2008 at 04:59:35PM +0900, Joonwoo Park escreveu:
> discard llc packet which has bogus packet length.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Dave, can you please apply this one?

>  net/llc/llc_input.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
> index c40c9b2..bfd2567 100644
> --- a/net/llc/llc_input.c
> +++ b/net/llc/llc_input.c
> @@ -117,8 +117,12 @@ static inline int llc_fixup_skb(struct sk_buff *skb)
>  	skb_pull(skb, llc_len);
>  	if (skb->protocol == htons(ETH_P_802_2)) {
>  		__be16 pdulen = eth_hdr(skb)->h_proto;
> -		u16 data_size = ntohs(pdulen) - llc_len;
> +		s32 data_size = ntohs(pdulen) - llc_len;
>  
> +		if (data_size < 0 ||
> +		    ((skb_tail_pointer(skb) -
> +		      (u8 *)pdu) - llc_len) < data_size)
> +			return 0;
>  		if (unlikely(pskb_trim_rcsum(skb, data_size)))
>  			return 0;
>  	}
> -- 
> 1.5.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
