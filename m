From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 2/4] sctp: remove the repeat initialize with 0
Date: Fri, 25 Oct 2013 19:42:08 -0400
Message-ID: <526B01D0.7090403@gmail.com>
References: <1382665805-13952-1-git-send-email-wangweidong1@huawei.com> <1382665805-13952-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>, davem@davemloft.net,
	nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:42284 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686Ab3JYXmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:42:20 -0400
In-Reply-To: <1382665805-13952-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2013 09:50 PM, Wang Weidong wrote:
> kmem_cache_zalloc had set the allocated memory to zero. I think no need
> to initialize with 0. And move the comments to the function begin.
>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>


Yes, thank you.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/sm_make_chunk.c | 29 ++++++++---------------------
>   1 file changed, 8 insertions(+), 21 deletions(-)
>
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index d244a23..fe69032 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -1297,6 +1297,13 @@ struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc)
>
>   /* Turn an skb into a chunk.
>    * FIXME: Eventually move the structure directly inside the skb->cb[].
> + *
> + * sctpimpguide-05.txt Section 2.8.2
> + * M1) Each time a new DATA chunk is transmitted
> + * set the 'TSN.Missing.Report' count for that TSN to 0. The
> + * 'TSN.Missing.Report' count will be used to determine missing chunks
> + * and when to fast retransmit.
> + *
>    */
>   struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
>   			    const struct sctp_association *asoc,
> @@ -1314,29 +1321,9 @@ struct sctp_chunk *sctp_chunkify(struct sk_buff *skb,
>   	INIT_LIST_HEAD(&retval->list);
>   	retval->skb		= skb;
>   	retval->asoc		= (struct sctp_association *)asoc;
> -	retval->has_tsn		= 0;
> -	retval->has_ssn         = 0;
> -	retval->rtt_in_progress	= 0;
> -	retval->sent_at		= 0;
>   	retval->singleton	= 1;
> -	retval->end_of_packet	= 0;
> -	retval->ecn_ce_done	= 0;
> -	retval->pdiscard	= 0;
> -
> -	/* sctpimpguide-05.txt Section 2.8.2
> -	 * M1) Each time a new DATA chunk is transmitted
> -	 * set the 'TSN.Missing.Report' count for that TSN to 0. The
> -	 * 'TSN.Missing.Report' count will be used to determine missing chunks
> -	 * and when to fast retransmit.
> -	 */
> -	retval->tsn_missing_report = 0;
> -	retval->tsn_gap_acked = 0;
> -	retval->fast_retransmit = SCTP_CAN_FRTX;
>
> -	/* If this is a fragmented message, track all fragments
> -	 * of the message (for SEND_FAILED).
> -	 */
> -	retval->msg = NULL;
> +	retval->fast_retransmit = SCTP_CAN_FRTX;
>
>   	/* Polish the bead hole.  */
>   	INIT_LIST_HEAD(&retval->transmitted_list);
>
