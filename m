From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next stable v2] sctp: fully initialize sctp_outq in
 sctp_outq_init
Date: Wed, 12 Jun 2013 14:40:16 -0400
Message-ID: <51B8C090.8050502@gmail.com>
References: <1371061604-27312-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:55165 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612Ab3FLSkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 14:40:20 -0400
In-Reply-To: <1371061604-27312-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 02:26 PM, Neil Horman wrote:
> In commit 2f94aabd9f6c925d77aecb3ff020f1cc12ed8f86
> (refactor sctp_outq_teardown to insure proper re-initalization)
> we modified sctp_outq_teardown to use sctp_outq_init to fully re-initalize the
> outq structure.  Steve West recently asked me why I removed the q->error = 0
> initalization from sctp_outq_teardown.  I did so because I was operating under
> the impression that sctp_outq_init would properly initalize that value for us,
> but it doesn't.  sctp_outq_init operates under the assumption that the outq
> struct is all 0's (as it is when called from sctp_association_init), but using
> it in __sctp_outq_teardown violates that assumption. We should do a memset in
> sctp_outq_init to ensure that the entire structure is in a known state there
> instead.
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: "West, Steve (NSN - US/Fort Worth)" <steve.west@nsn.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> CC: netdev@vger.kernel.org
> CC: davem@davemloft.net
> ---
>   net/sctp/outqueue.c | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 32a4625..be35e2d 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -206,6 +206,8 @@ static inline int sctp_cacc_skip(struct sctp_transport *primary,
>    */
>   void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
>   {
> +	memset(q, 0, sizeof(struct sctp_outq));
> +
>   	q->asoc = asoc;
>   	INIT_LIST_HEAD(&q->out_chunk_list);
>   	INIT_LIST_HEAD(&q->control_chunk_list);
> @@ -213,11 +215,7 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
>   	INIT_LIST_HEAD(&q->sacked);
>   	INIT_LIST_HEAD(&q->abandoned);
>
> -	q->fast_rtx = 0;
> -	q->outstanding_bytes = 0;
>   	q->empty = 1;
> -	q->cork  = 0;
> -	q->out_qlen = 0;
>   }
>
>   /* Free the outqueue structure and any related pending chunks.
>
