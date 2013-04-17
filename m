From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 4/9] net: sctp: sctp_outq: consolidate chars
 into bitfield
Date: Wed, 17 Apr 2013 11:31:25 -0400
Message-ID: <20130417153125.GE5149@hmsreliant.think-freely.org>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
 <1366146438-8815-5-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53366 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964900Ab3DQPbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 11:31:32 -0400
Content-Disposition: inline
In-Reply-To: <1366146438-8815-5-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 11:07:13PM +0200, Daniel Borkmann wrote:
> sctp_outq structure members fast_rtx, cork and empty are all
> of type char. Consolidate them into a single __u8 bitfield since
> they either carry 0 or 1. Have the rest 5 bits for future flags.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/sctp/structs.h | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 73fd5de..3de5985 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1051,14 +1051,9 @@ struct sctp_outq {
>  	/* How many unackd bytes do we have in-flight?	*/
>  	__u32 outstanding_bytes;
>  
> -	/* Are we doing fast-rtx on this queue */
> -	char fast_rtx;
> -
> -	/* Corked? */
> -	char cork;
> -
> -	/* Is this structure empty?  */
> -	char empty;
> +	__u8 fast_rtx:1,	/* Are we doing fast-rtx on this queue */
> +	     cork:1,		/* Corked? */
> +	     empty:1;		/* Is this structure empty?  */
>  };
>  
>  void sctp_outq_init(struct sctp_association *, struct sctp_outq *);
> -- 
> 1.7.11.7
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
