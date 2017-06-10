From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net-next] sctp: no need to check assoc id before
 calling sctp_assoc_set_id
Date: Sat, 10 Jun 2017 13:03:13 -0300
Message-ID: <20170610160313.GD5799@localhost.localdomain>
References: <ea556c7733c5bf63532ce35186e4bc7a519bf858.1497079632.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47196 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751912AbdFJQDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 12:03:16 -0400
Content-Disposition: inline
In-Reply-To: <ea556c7733c5bf63532ce35186e4bc7a519bf858.1497079632.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 10, 2017 at 03:27:12PM +0800, Xin Long wrote:
> sctp_assoc_set_id does the assoc id check in the beginning when
> processing dupcookie, no need to do the same check before calling
> it.
> 
> v1->v2:
>   fix some typo errs Marcelo pointed in changelog.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/associola.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 288c5e0..72b07dd 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1181,12 +1181,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
>  		if (sctp_state(asoc, COOKIE_WAIT))
>  			sctp_stream_update(&asoc->stream, &new->stream);
>  
> -		if (!asoc->assoc_id) {
> -			/* get a new association id since we don't have one
> -			 * yet.
> -			 */
> -			sctp_assoc_set_id(asoc, GFP_ATOMIC);
> -		}
> +		/* get a new assoc id if we don't have one yet. */
> +		sctp_assoc_set_id(asoc, GFP_ATOMIC);
>  	}
>  
>  	/* SCTP-AUTH: Save the peer parameters from the new associations
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
