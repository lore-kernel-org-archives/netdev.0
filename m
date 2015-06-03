From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Make the function sctp_chunk_abandoned bool
Date: Wed, 3 Jun 2015 06:22:54 -0400
Message-ID: <20150603102254.GA7234@hmsreliant.think-freely.org>
References: <1433304173-4367-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49834 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbbFCKXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 06:23:09 -0400
Content-Disposition: inline
In-Reply-To: <1433304173-4367-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 12:02:53AM -0400, Nicholas Krause wrote:
> This makes the function sctp_chunk_abandoned bool due to this
> function only returning either one or zero as its return value.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  include/net/sctp/structs.h | 2 +-
>  net/sctp/chunk.c           | 8 ++++----
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 2bb2fcf..2691490 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -535,7 +535,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *,
>  void sctp_datamsg_free(struct sctp_datamsg *);
>  void sctp_datamsg_put(struct sctp_datamsg *);
>  void sctp_chunk_fail(struct sctp_chunk *, int error);
> -int sctp_chunk_abandoned(struct sctp_chunk *);
> +bool sctp_chunk_abandoned(struct sctp_chunk *);
>  
>  /* RFC2960 1.4 Key Terms
>   *
> diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
> index a338091..7bd1991 100644
> --- a/net/sctp/chunk.c
> +++ b/net/sctp/chunk.c
> @@ -344,17 +344,17 @@ errout:
>  }
>  
>  /* Check whether this message has expired. */
> -int sctp_chunk_abandoned(struct sctp_chunk *chunk)
> +bool sctp_chunk_abandoned(struct sctp_chunk *chunk)
>  {
>  	struct sctp_datamsg *msg = chunk->msg;
>  
>  	if (!msg->can_abandon)
> -		return 0;
> +		return false;
>  
>  	if (time_after(jiffies, msg->expires_at))
> -		return 1;
> +		return true;
>  
> -	return 0;
> +	return false;
>  }
>  
>  /* This chunk (and consequently entire message) has failed in its sending. */
> -- 
> 2.1.4
> 
> 
Seems reasonable
Acked-by: Neil Horman <nhorman@tuxdriver.com>
