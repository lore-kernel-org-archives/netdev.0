From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: convert sack_needed and sack_generation to bits
Date: Mon, 30 Nov 2015 09:43:45 -0500
Message-ID: <565C60A1.1000001@gmail.com>
References: <f3803545e5d34adfe83cff5adf01317c56288d59.1448892562.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org,
	lucien.xin@gmail.com
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33523 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125AbbK3Ons (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 09:43:48 -0500
In-Reply-To: <f3803545e5d34adfe83cff5adf01317c56288d59.1448892562.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2015 09:17 AM, Marcelo Ricardo Leitner wrote:
> They don't need to be any bigger than that and with this we start a new
> bitfield for tracking association runtime stuff, like zero window
> situation.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
> 
> Motivated by https://patchwork.ozlabs.org/patch/509836/
> 
>  include/net/sctp/structs.h | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 495c87e367b3f2e8941807f56a77d2e14469bfed..7bbb71081aeb6cfdc9cb049cf7a094dbcd4603bb 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -775,10 +775,10 @@ struct sctp_transport {
>  		hb_sent:1,
>  
>  		/* Is the Path MTU update pending on this tranport */
> -		pmtu_pending:1;
> +		pmtu_pending:1,
>  
> -	/* Has this transport moved the ctsn since we last sacked */
> -	__u32 sack_generation;
> +		/* Has this transport moved the ctsn since we last sacked */
> +		sack_generation:1;
>  	u32 dst_cookie;
>  
>  	struct flowi fl;
> @@ -1482,19 +1482,19 @@ struct sctp_association {
>  			prsctp_capable:1,   /* Can peer do PR-SCTP? */
>  			auth_capable:1;     /* Is peer doing SCTP-AUTH? */
>  
> -		/* Ack State   : This flag indicates if the next received
> +		/* sack_needed : This flag indicates if the next received
>  		 *             : packet is to be responded to with a
> -		 *             : SACK. This is initializedto 0.  When a packet
> -		 *             : is received it is incremented. If this value
> +		 *             : SACK. This is initialized to 0.  When a packet
> +		 *             : is received sack_cnt is incremented. If this value
>  		 *             : reaches 2 or more, a SACK is sent and the
>  		 *             : value is reset to 0. Note: This is used only
>  		 *             : when no DATA chunks are received out of
>  		 *             : order.  When DATA chunks are out of order,
>  		 *             : SACK's are not delayed (see Section 6).
>  		 */
> -		__u8    sack_needed;     /* Do we need to sack the peer? */
> +		__u8    sack_needed:1,     /* Do we need to sack the peer? */
> +			sack_generation:1;
>  		__u32	sack_cnt;
> -		__u32	sack_generation;
>  
>  		__u32   adaptation_ind;	 /* Adaptation Code point. */
>  
> 
