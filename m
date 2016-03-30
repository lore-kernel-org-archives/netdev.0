From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: really allow using GFP_KERNEL on
 sctp_packet_transmit
Date: Wed, 30 Mar 2016 07:45:57 -0400
Message-ID: <20160330114556.GA15549@hmsreliant.think-freely.org>
References: <1459258863-21351-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58962 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbcC3LqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 07:46:09 -0400
Content-Disposition: inline
In-Reply-To: <1459258863-21351-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2016 at 10:41:03AM -0300, Marcelo Ricardo Leitner wrote:
> Somehow my patch for commit cea8768f333e ("sctp: allow
> sctp_transmit_packet and others to use gfp") missed two important
> chunks, which are now added.
> 
> Fixes: cea8768f333e ("sctp: allow sctp_transmit_packet and others to use gfp")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/output.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 736c004abfbc2787a3c50fa85168ebdf3b112787..97745351d58c2fb32b9f9b57d61831d7724d83b2 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -401,7 +401,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  	sk = chunk->skb->sk;
>  
>  	/* Allocate the new skb.  */
> -	nskb = alloc_skb(packet->size + MAX_HEADER, GFP_ATOMIC);
> +	nskb = alloc_skb(packet->size + MAX_HEADER, gfp);
>  	if (!nskb)
>  		goto nomem;
>  
> @@ -523,8 +523,8 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
>  	 */
>  	if (auth)
>  		sctp_auth_calculate_hmac(asoc, nskb,
> -					(struct sctp_auth_chunk *)auth,
> -					GFP_ATOMIC);
> +					 (struct sctp_auth_chunk *)auth,
> +					 gfp);
>  
>  	/* 2) Calculate the Adler-32 checksum of the whole packet,
>  	 *    including the SCTP common header and all the
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-By: Neil Horman <nhorman@tuxdriver.com>
