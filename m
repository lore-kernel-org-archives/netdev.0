From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v4 net-next] l2tp: Refactor the codes with existing
 macros instead of literal number
Date: Mon, 22 Aug 2016 16:43:58 +0200
Message-ID: <20160822144358.m5jwuzvmgic4e7xw@alphalink.fr>
References: <1471863591-6790-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, philipp@redfish-solutions.com,
        davem@davemloft.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:43455 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932407AbcHVOoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 10:44:05 -0400
Content-Disposition: inline
In-Reply-To: <1471863591-6790-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 06:59:51PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
> 0x03, and 2 separately.
> 
Apart from the checkpatch errors,

Acked-by: Guillaume Nault <g.nault@alphalink.fr>

> @@ -325,8 +324,8 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
>  	skb_reserve(skb, uhlen);
>  
>  	/* Add PPP header */
> -	skb->data[0] = ppph[0];
> -	skb->data[1] = ppph[1];
> +	skb->data[0] = PPP_ALLSTATIONS; 
> 
Trailing whitespace.

> @@ -398,14 +396,14 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
>  		   sizeof(struct iphdr) + /* IP header */
>  		   uhlen +		/* UDP header (if L2TP_ENCAPTYPE_UDP) */
>  		   session->hdr_len +	/* L2TP header */
> -		   sizeof(ppph);	/* PPP header */
> +		   2;			/* 2 bytes for PPP_ALLSTATIONS & PPP_UI */
>  	if (skb_cow_head(skb, headroom))
>  		goto abort_put_sess_tun;
>  
>  	/* Setup PPP header */
> -	__skb_push(skb, sizeof(ppph));
> -	skb->data[0] = ppph[0];
> -	skb->data[1] = ppph[1];
> +	__skb_push(skb, 2); 
> 
Here too.
