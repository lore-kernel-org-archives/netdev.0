From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: fix the fast retransmit limit
Date: Thu, 3 Mar 2011 06:41:16 -0500
Message-ID: <20110303114116.GA5146@hmsreliant.think-freely.org>
References: <4D6F5F83.705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>,
	Mingyuan Zhu <liyha.zhu@gmail.com>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37767 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757770Ab1CCLl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 06:41:28 -0500
Content-Disposition: inline
In-Reply-To: <4D6F5F83.705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2011 at 05:29:39PM +0800, Wei Yongjun wrote:
> If chunk is still lost after fast retransmit, SCTP stack will
> never allow the second fast retransmit of this chunk, even if
> the peer need we do this. This chunk will be retransmit until
> the rtx timeout. This limit is introduce by the following patch:
>   sctp: reduce memory footprint of sctp_chunk structure
>   (c226ef9b83694311327f3ab0036c6de9c22e9daf)
> 
> This patch revert this limit and removed useless SCTP_DONT_FRTX.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> ---
>  include/net/sctp/structs.h |    1 -
>  net/sctp/outqueue.c        |    4 ++--
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index cc9185c..82a0f84 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -751,7 +751,6 @@ struct sctp_chunk {
>  
>  #define SCTP_CAN_FRTX 0x0
>  #define SCTP_NEED_FRTX 0x1
> -#define SCTP_DONT_FRTX 0x2
>  	__u16	rtt_in_progress:1,	/* This chunk used for RTT calc? */
>  		has_tsn:1,		/* Does this chunk have a TSN yet? */
>  		has_ssn:1,		/* Does this chunk have a SSN yet? */
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 8c6d379..7ed5862 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -657,7 +657,7 @@ redo:
>  			 * after it is retransmitted.
>  			 */
>  			if (chunk->fast_retransmit == SCTP_NEED_FRTX)
> -				chunk->fast_retransmit = SCTP_DONT_FRTX;
> +				chunk->fast_retransmit = SCTP_CAN_FRTX;
>  
>  			q->empty = 0;
>  			break;
> @@ -679,7 +679,7 @@ redo:
>  	if (rtx_timeout || fast_rtx) {
>  		list_for_each_entry(chunk1, lqueue, transmitted_list) {
>  			if (chunk1->fast_retransmit == SCTP_NEED_FRTX)
> -				chunk1->fast_retransmit = SCTP_DONT_FRTX;
> +				chunk1->fast_retransmit = SCTP_CAN_FRTX;
>  		}
>  	}
>  
> -- 
> 1.6.5.2
> 
> 
> 
