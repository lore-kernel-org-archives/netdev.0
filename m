From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: sctp_assoc_control_transport: fix MTU
 size in SCTP_PF state
Date: Sun, 11 Aug 2013 12:16:45 -0400
Message-ID: <20130811161645.GA29543@neilslaptop.think-freely.org>
References: <1376053748-31783-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kheiss@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47148 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132Ab3HKQRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 12:17:12 -0400
Content-Disposition: inline
In-Reply-To: <1376053748-31783-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 09, 2013 at 03:09:08PM +0200, Daniel Borkmann wrote:
> The SCTP Quick failover draft [1] section 5.1, point 5 says that the cwnd
> should be 1 MTU. So, instead of 1, set it to 1 MTU.
> 
>   [1] https://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05
> 
> Reported-by: Karl Heiss <kheiss@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> ---
>  net/sctp/associola.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index bce5b79..ab67efc 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -846,12 +846,12 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
>  		else
>  			spc_state = SCTP_ADDR_AVAILABLE;
>  		/* Don't inform ULP about transition from PF to
> -		 * active state and set cwnd to 1, see SCTP
> +		 * active state and set cwnd to 1 MTU, see SCTP
>  		 * Quick failover draft section 5.1, point 5
>  		 */
>  		if (transport->state == SCTP_PF) {
>  			ulp_notify = false;
> -			transport->cwnd = 1;
> +			transport->cwnd = asoc->pathmtu;
>  		}
>  		transport->state = SCTP_ACTIVE;
>  		break;
> -- 
> 1.7.11.7
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
