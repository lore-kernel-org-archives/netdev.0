From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 2/3] sctp: return back transport in
 __sctp_rcv_init_lookup
Date: Fri, 28 Oct 2016 17:42:21 -0200
Message-ID: <20161028194221.GC4193@localhost.localdomain>
References: <cover.1477649076.git.lucien.xin@gmail.com>
 <5ebf537ea021af594ca1b2538d28a3080d5c3ee7.1477649076.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
        daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47612 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756698AbcJ1TmY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 15:42:24 -0400
Content-Disposition: inline
In-Reply-To: <5ebf537ea021af594ca1b2538d28a3080d5c3ee7.1477649076.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2016 at 06:10:53PM +0800, Xin Long wrote:
> Prior to this patch, it used a local variable to save the transport that is
> looked up by __sctp_lookup_association(), and didn't return it back. But in
> sctp_rcv, it is used to initialize chunk->transport. So when hitting this
> code, it was initializing chunk->transport with some random stack value
> instead.
> 
> This patch is to return the transport back through transport pointer
> that is from __sctp_rcv_lookup_harder().
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

transport pointer in sctp_rcv() is initialized to null and there are
checks for it after this path, so this shouldn't be exploitable, just
malfunction.

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
