From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: flush if we can't fit another DATA chunk
Date: Wed, 30 Mar 2016 08:03:57 -0400
Message-ID: <20160330120357.GB15549@hmsreliant.think-freely.org>
References: <1459258885-21502-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59205 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbcC3MEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 08:04:11 -0400
Content-Disposition: inline
In-Reply-To: <1459258885-21502-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2016 at 10:41:25AM -0300, Marcelo Ricardo Leitner wrote:
> There is no point in delaying the packet if we can't fit a single byte
> of data on it anymore. So lets just reduce the threshold by the amount
> that a data chunk with 4 bytes (rounding) would use.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/output.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 97745351d58c2fb32b9f9b57d61831d7724d83b2..c518569123ce42a8f21f80754756306c39875013 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -705,7 +705,8 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
>  	/* Check whether this chunk and all the rest of pending data will fit
>  	 * or delay in hopes of bundling a full sized packet.
>  	 */
> -	if (chunk->skb->len + q->out_qlen >= transport->pathmtu - packet->overhead)
> +	if (chunk->skb->len + q->out_qlen >
> +		maxsize - packet->overhead - sizeof(sctp_data_chunk_t) - 4)
>  		/* Enough data queued to fill a packet */
>  		return SCTP_XMIT_OK;
>  
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Acked-By: Neil Horman <nhorman@tuxdriver.com>
