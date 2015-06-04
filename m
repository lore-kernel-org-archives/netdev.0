From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp:Make the function sctp_assoc_lookup_laddr bool
Date: Thu, 4 Jun 2015 06:35:03 -0400
Message-ID: <20150604103503.GA24585@hmsreliant.think-freely.org>
References: <1433335867-1871-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42498 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbbFDKfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 06:35:25 -0400
Content-Disposition: inline
In-Reply-To: <1433335867-1871-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 08:51:07AM -0400, Nicholas Krause wrote:
> This makes the function sctp_assoc_lookup_laddr bool due to this
> function only returning either one or zero as its return value.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  include/net/sctp/structs.h | 4 ++--
>  net/sctp/associola.c       | 8 ++++----
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 2bb2fcf..1381be9 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1870,8 +1870,8 @@ struct sctp_transport *sctp_assoc_choose_alter_transport(
>  void sctp_assoc_update_retran_path(struct sctp_association *);
>  struct sctp_transport *sctp_assoc_lookup_paddr(const struct sctp_association *,
>  					  const union sctp_addr *);
> -int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> -			    const union sctp_addr *laddr);
> +bool sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> +			     const union sctp_addr *laddr);
>  struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *,
>  				     const union sctp_addr *address,
>  				     const gfp_t gfp,
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 197c3f5..69abe78 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1572,15 +1572,15 @@ int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *asoc,
>  }
>  
>  /* Lookup laddr in the bind address list of an association. */
> -int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> -			    const union sctp_addr *laddr)
> +bool sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> +			     const union sctp_addr *laddr)
>  {
> -	int found = 0;
> +	bool found = false;
>  
>  	if ((asoc->base.bind_addr.port == ntohs(laddr->v4.sin_port)) &&
>  	    sctp_bind_addr_match(&asoc->base.bind_addr, laddr,
>  				 sctp_sk(asoc->base.sk)))
> -		found = 1;
> +		found = true;
>  
>  	return found;
>  }
> -- 
> 2.1.4
> 
> 

If you're going to do this, you might as well also remove the conditional
statement here entirely.  I.e. just have the function be this:

return (asoc->base.bind_addr.port == ntohs(laddr->v4.sin_port)) &&
	sctp_bind_addr_match(&asoc->base.bind_addr, laddr,
	sctp_sk(asoc->base.sk)));

You might also look into makeing it inline, though it doesn't appear in any hot
paths so thats likely overkill

Neil
