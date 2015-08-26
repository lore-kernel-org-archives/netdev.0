From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sctp: donot reset the overall_error_count in
 SHUTDOWN_RECEIVE state
Date: Tue, 25 Aug 2015 19:46:57 -0700 (PDT)
Message-ID: <20150825.194657.206783179556219937.davem@davemloft.net>
References: <46eeeb896c5be2523e3d978d4a7ea9907d4301ee.1440329415.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mleitner@redhat.com, tgraf@infradead.org,
	vyasevich@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbHZCq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 22:46:58 -0400
In-Reply-To: <46eeeb896c5be2523e3d978d4a7ea9907d4301ee.1440329415.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 23 Aug 2015 19:30:15 +0800

Vlad et al., please review.

> commit f8d960524 fix the 0 peer.rwnd issue in SHUTDOWN_PENDING state through
> not reseting the overall_error_count when receive a heartbeat, but the same
> issue also exists in SHUTDOWN_RECEIVE state.
> 
> so we change the condition to state < SCTP_STATE_SHUTDOWN_PENDING to reset the
> overall_error_count when receive a heartbeat, which can avoid the issue happen
> in SCTP_STATE_SHUTDOWN_RECEIVE.
> 
> as to SCTP_STATE_SHUTDOWN_ACK_SENT and SCTP_STATE_SHUTDOWN_SENT state, with
> this patch, it will not be affected by the heartbeat, cause these two states
> have been taken charge of by t2 timer.
> 
> Fixes: f8d960524 ("sctp: Enforce retransmission limit during shutdown")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/sm_sideeffect.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index fef2acd..85e6f03 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -702,7 +702,7 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
>  	 * outstanding data and rely on the retransmission limit be reached
>  	 * to shutdown the association.
>  	 */
> -	if (t->asoc->state != SCTP_STATE_SHUTDOWN_PENDING)
> +	if (t->asoc->state < SCTP_STATE_SHUTDOWN_PENDING)
>  		t->asoc->overall_error_count = 0;
>  
>  	/* Clear the hb_sent flag to signal that we had a good
> -- 
> 2.1.0
> 
