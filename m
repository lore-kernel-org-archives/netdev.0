From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net 2/3] sctp: return back transport in
 __sctp_rcv_init_lookup
Date: Mon, 31 Oct 2016 18:14:45 -0200
Message-ID: <20161031201445.GD8514@localhost.localdomain>
References: <cover.1477916928.git.lucien.xin@gmail.com>
 <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477916928.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53228 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S946301AbcJaUOs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 16:14:48 -0400
Content-Disposition: inline
In-Reply-To: <8d72a86988a2c16c74c45c52dafbf2bbbe9c3b4d.1477916928.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 08:32:32PM +0800, Xin Long wrote:
> Prior to this patch, it used a local variable to save the transport that is
> looked up by __sctp_lookup_association(), and didn't return it back. But in
> sctp_rcv, it is used to initialize chunk->transport. So when hitting this,
> even if it found the transport, it was still initializing chunk->transport
> with null instead.
> 
> This patch is to return the transport back through transport pointer
> that is from __sctp_rcv_lookup_harder().
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/input.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index a2ea1d1..8e0bc58 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -1021,7 +1021,6 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
>  	struct sctphdr *sh = sctp_hdr(skb);
>  	union sctp_params params;
>  	sctp_init_chunk_t *init;
> -	struct sctp_transport *transport;
>  	struct sctp_af *af;
>  
>  	/*
> @@ -1052,7 +1051,7 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
>  
>  		af->from_addr_param(paddr, params.addr, sh->source, 0);
>  
> -		asoc = __sctp_lookup_association(net, laddr, paddr, &transport);
> +		asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
>  		if (asoc)
>  			return asoc;
>  	}
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
