From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: start t5 timer only when peer.rwnd == 0 and in
 SHUTDOWN_PENDING
Date: Wed, 19 Aug 2015 14:49:37 -0300
Message-ID: <20150819174937.GP1097@localhost.localdomain>
References: <b28d94a321679707da72c7a1d52fc49fbb3bcea3.1439959146.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, tgraf@infradead.org,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37176 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbbHSRtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 13:49:40 -0400
Content-Disposition: inline
In-Reply-To: <b28d94a321679707da72c7a1d52fc49fbb3bcea3.1439959146.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 12:39:06PM +0800, Xin Long wrote:
> when A send a data to B, A close() to be in SHUTDOWN_PENDING state,
> but B neither claim his rwnd is 0 nor SACK this data, then A keep
> retransmiting this data. it should send abord after Max.Retrans
> times, only when peer.rwnd == 0 and more than Max.Retrans times, it
> will start t5 timer.
> 
> Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---

changelog is confusing, please reword it, specially the last part.

>  net/sctp/sm_statefuns.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 3ee27b7..7d9380c 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -5412,7 +5412,8 @@ sctp_disposition_t sctp_sf_do_6_3_3_rtx(struct net *net,
>  	SCTP_INC_STATS(net, SCTP_MIB_T3_RTX_EXPIREDS);
>  
>  	if (asoc->overall_error_count >= asoc->max_retrans) {
> -		if (asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
> +		if (!q->asoc->peer.rwnd &&
> +			asoc->state == SCTP_STATE_SHUTDOWN_PENDING) {
                    ^

Indentation issue here. 2nd if line should start where I marked.

Other than that, looks good to me.

>  			/*
>  			 * We are here likely because the receiver had its rwnd
>  			 * closed for a while and we have not been able to
> -- 
> 2.1.0
> 
