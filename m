From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 6/9] net: sctp: sctp_transport: remove unused
 variable
Date: Wed, 17 Apr 2013 11:34:07 -0400
Message-ID: <20130417153407.GG5149@hmsreliant.think-freely.org>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
 <1366146438-8815-7-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53463 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964900Ab3DQPeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 11:34:13 -0400
Content-Disposition: inline
In-Reply-To: <1366146438-8815-7-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 11:07:15PM +0200, Daniel Borkmann wrote:
> sctp_transport's member 'malloced' is set to 1, never evaluated
> and the structure is kfreed anyway. So just remove it.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/sctp/structs.h | 5 +----
>  net/sctp/transport.c       | 1 -
>  2 files changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 3de5985..945e952 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -779,10 +779,7 @@ struct sctp_transport {
>  		hb_sent:1,
>  
>  		/* Is the Path MTU update pending on this tranport */
> -		pmtu_pending:1,
> -
> -		/* Is this structure kfree()able? */
> -		malloced:1;
> +		pmtu_pending:1;
>  
>  	/* Has this transport moved the ctsn since we last sacked */
>  	__u32 sack_generation;
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index fafd2a4..098f1d5f 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -123,7 +123,6 @@ struct sctp_transport *sctp_transport_new(struct net *net,
>  	if (!sctp_transport_init(net, transport, addr, gfp))
>  		goto fail_init;
>  
> -	transport->malloced = 1;
>  	SCTP_DBG_OBJCNT_INC(transport);
>  
>  	return transport;
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
