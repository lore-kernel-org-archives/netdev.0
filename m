From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v3 2/3] net: sctp: Rename SCTP_XMIT_NAGLE_DELAY
 to SCTP_XMIT_DELAY
Date: Tue, 22 Jul 2014 09:03:01 -0400
Message-ID: <53CE6105.3020302@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF03@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:33222 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaGVNDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 09:03:05 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727AF03@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 04:59 AM, David Laight wrote:
> MSG_MORE and 'corking' a socket would require that the transmit of
> a data chunk be delayed.
> Rename the return value to be less specific.
> 
> Signed-off-by: David Laight <david.laight@aculab.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
> 
> Resend with corrected subject line.
> 
> No change from v2.
> 
>  include/net/sctp/constants.h | 2 +-
>  net/sctp/output.c            | 4 ++--
>  net/sctp/outqueue.c          | 4 ++--
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
> index 307728f..8c337cd 100644
> --- a/include/net/sctp/constants.h
> +++ b/include/net/sctp/constants.h
> @@ -311,7 +311,7 @@ typedef enum {
>  	SCTP_XMIT_OK,
>  	SCTP_XMIT_PMTU_FULL,
>  	SCTP_XMIT_RWND_FULL,
> -	SCTP_XMIT_NAGLE_DELAY,
> +	SCTP_XMIT_DELAY,
>  } sctp_xmit_t;
>  
>  /* These are the commands for manipulating transports.  */
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 553ba1d..7f28a8e 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -178,7 +178,7 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
>  
>  	case SCTP_XMIT_RWND_FULL:
>  	case SCTP_XMIT_OK:
> -	case SCTP_XMIT_NAGLE_DELAY:
> +	case SCTP_XMIT_DELAY:
>  		break;
>  	}
>  
> @@ -712,7 +712,7 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
>  		return SCTP_XMIT_OK;
>  
>  	/* Defer until all data acked or packet full */
> -	return SCTP_XMIT_NAGLE_DELAY;
> +	return SCTP_XMIT_DELAY;
>  }
>  
>  /* This private function does management things when adding DATA chunk */
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 9c77947..9ce0f3d 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -629,7 +629,7 @@ redo:
>  			done = 1;
>  			break;
>  
> -		case SCTP_XMIT_NAGLE_DELAY:
> +		case SCTP_XMIT_DELAY:
>  			/* Send this packet. */
>  			error = sctp_packet_transmit(pkt);
>  
> @@ -1015,7 +1015,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  			switch (status) {
>  			case SCTP_XMIT_PMTU_FULL:
>  			case SCTP_XMIT_RWND_FULL:
> -			case SCTP_XMIT_NAGLE_DELAY:
> +			case SCTP_XMIT_DELAY:
>  				/* We could not append this chunk, so put
>  				 * the chunk back on the output queue.
>  				 */
> 
