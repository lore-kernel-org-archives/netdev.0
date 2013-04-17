From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/9] net: sctp: sctp_inq: remove dead code
Date: Wed, 17 Apr 2013 08:47:34 -0400
Message-ID: <20130417124734.GB5149@hmsreliant.think-freely.org>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
 <1366146438-8815-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50739 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966141Ab3DQMrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 08:47:39 -0400
Content-Disposition: inline
In-Reply-To: <1366146438-8815-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 11:07:11PM +0200, Daniel Borkmann wrote:
> sctp_inq is never kmalloced, since it's integrated into sctp_ep_common
> and only initialized from eps and assocs. Therefore, remove the dead
> code from there.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/sctp/structs.h | 2 --
>  net/sctp/inqueue.c         | 7 -------
>  2 files changed, 9 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 3c1bb8d..125a19c 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -991,8 +991,6 @@ struct sctp_inq {
>  	 * messages.
>  	 */
>  	struct work_struct immediate;
> -
> -	int malloced;	     /* Is this structure kfree()able?	*/
>  };
>  
>  void sctp_inq_init(struct sctp_inq *);
> diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
> index 2d5ad28..3221d07 100644
> --- a/net/sctp/inqueue.c
> +++ b/net/sctp/inqueue.c
> @@ -58,8 +58,6 @@ void sctp_inq_init(struct sctp_inq *queue)
>  
>  	/* Create a task for delivering data.  */
>  	INIT_WORK(&queue->immediate, NULL);
> -
> -	queue->malloced = 0;
>  }
>  
>  /* Release the memory associated with an SCTP inqueue.  */
> @@ -80,11 +78,6 @@ void sctp_inq_free(struct sctp_inq *queue)
>  		sctp_chunk_free(queue->in_progress);
>  		queue->in_progress = NULL;
>  	}
> -
> -	if (queue->malloced) {
> -		/* Dump the master memory segment.  */
> -		kfree(queue);
> -	}
>  }
>  
Acked-by: Neil Horman <nhorman@tuxdriver.com>
