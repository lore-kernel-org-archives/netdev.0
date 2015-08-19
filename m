From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: donot reset the overall_error_count in
 SHUTDOWN_RECEIVE state
Date: Wed, 19 Aug 2015 14:58:37 -0300
Message-ID: <20150819175837.GQ1097@localhost.localdomain>
References: <9750de643075d301d80229898eacb0d921349f73.1439959083.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, tgraf@infradead.org,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbbHSR6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 13:58:40 -0400
Content-Disposition: inline
In-Reply-To: <9750de643075d301d80229898eacb0d921349f73.1439959083.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 12:38:03PM +0800, Xin Long wrote:
> commit f8d960524 fix the 0 peer.rwnd issue in SHUTDOWN_PENING state
> through not reseting the overall_error_count when recevie a heartbeat,
> but the same issue also exists in SHUTDOWN_RECEIVE state.

Please fix the typos on changelog, specially when regarding symbols so
searching for them later is more successful.

Also, to make changelog closer to the actual change, explaining why it's
okay to include the other states in there too would be good, as you're
including not only SHUTDOWN_RECEIVE but also SHUTDOWN_SENT and
SHUTDOWN_ACK_SENT.

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
