From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net-next 2/5] {IPv4,xfrm} Add ESN support for AH
 ingress part
Date: Tue, 14 Jan 2014 10:54:25 +0100
Message-ID: <20140114095425.GH31491@secunet.com>
References: <1389663552-29638-1-git-send-email-fan.du@windriver.com>
 <1389663552-29638-3-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35740 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbaANJy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 04:54:28 -0500
Content-Disposition: inline
In-Reply-To: <1389663552-29638-3-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 09:39:09AM +0800, Fan Du wrote:
> @@ -381,7 +393,14 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
>  	sg_init_table(sg, nfrags);
>  	skb_to_sgvec(skb, sg, 0, skb->len);
>  
> -	ahash_request_set_crypt(req, sg, icv, skb->len);
> +	if (x->props.flags & XFRM_STATE_ESN) {
> +		sg_unmark_end(&sg[nfrags - 1]);
> +		/* Attach seqhi sg right after packet payload */
> +		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);

This is ah_input(), so you should use the high bits of the input
sequence number here. The ipv6 patch has the same problem.

> +		sg_init_table(seqhisg, sglists);

Why do you add a separate SG table for this?
