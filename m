From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: fix a success return may hide an error
Date: Thu, 11 Aug 2016 11:36:28 -0400
Message-ID: <20160811153628.GA6646@hmsreliant.think-freely.org>
References: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40594 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190AbcHKPhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 11:37:05 -0400
Content-Disposition: inline
In-Reply-To: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2016 at 08:52:58PM +0800, Xin Long wrote:
> Now in the end of sctp_outq_flush, sctp calls sctp_packet_transmit
> in a loop. The return of current sctp_packet_transmit always covers
> the prior one's. If the last call of sctp_packet_transmit return a
> success, it may hide the error that returns from the prior call.
> 
> This patch is to fix this by keeping the old error until the new
> error returns from sctp_packet_transmit. Did TAHI test against this
> fix, no regression is found.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/outqueue.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 72e54a4..b97c8ad 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -1193,7 +1193,7 @@ sctp_flush_out:
>  						      send_ready);
>  		packet = &t->packet;
>  		if (!sctp_packet_empty(packet))
> -			error = sctp_packet_transmit(packet, gfp);
> +			error = sctp_packet_transmit(packet, gfp) ? : error;
>  
>  		/* Clear the burst limited state, if any */
>  		sctp_transport_burst_reset(t);
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
