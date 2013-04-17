From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 7/9] net: sctp: sctp_bind_addr: remove dead code
Date: Wed, 17 Apr 2013 11:35:26 -0400
Message-ID: <20130417153526.GH5149@hmsreliant.think-freely.org>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
 <1366146438-8815-8-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53494 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966772Ab3DQPfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 11:35:32 -0400
Content-Disposition: inline
In-Reply-To: <1366146438-8815-8-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 11:07:16PM +0200, Daniel Borkmann wrote:
> The sctp_bind_addr structure has a 'malloced' member that is
> always set to 0, thus in sctp_bind_addr_free() the kfree()
> part can never be called. This part is embedded into
> sctp_ep_common anyway and never alloced.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/sctp/structs.h | 2 --
>  net/sctp/bind_addr.c       | 7 -------
>  2 files changed, 9 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 945e952..b4e9894 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1088,8 +1088,6 @@ struct sctp_bind_addr {
>  	 *	peer(s) in INIT and INIT ACK chunks.
>  	 */
>  	struct list_head address_list;
> -
> -	int malloced;	     /* Are we kfree()able?  */
>  };
>  
>  void sctp_bind_addr_init(struct sctp_bind_addr *, __u16 port);
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index d886b3b..41145fe 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -131,8 +131,6 @@ int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
>   */
>  void sctp_bind_addr_init(struct sctp_bind_addr *bp, __u16 port)
>  {
> -	bp->malloced = 0;
> -
>  	INIT_LIST_HEAD(&bp->address_list);
>  	bp->port = port;
>  }
> @@ -155,11 +153,6 @@ void sctp_bind_addr_free(struct sctp_bind_addr *bp)
>  {
>  	/* Empty the bind address list. */
>  	sctp_bind_addr_clean(bp);
> -
> -	if (bp->malloced) {
> -		kfree(bp);
> -		SCTP_DBG_OBJCNT_DEC(bind_addr);
> -	}
>  }
>  
>  /* Add an address to the bind address list in the SCTP_bind_addr structure. */
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
