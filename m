From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: no need to check asoc_id before calling
 sctp_assoc_set_id
Date: Tue, 23 May 2017 15:04:25 -0300
Message-ID: <20170523180425.GH4642@localhost.localdomain>
References: <8ccb4ee656bcdfa790e4f3ee919bb300e4adc4cc.1495521032.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52158 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965420AbdEWSEf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 14:04:35 -0400
Content-Disposition: inline
In-Reply-To: <8ccb4ee656bcdfa790e4f3ee919bb300e4adc4cc.1495521032.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, May 23, 2017 at 02:30:32PM +0800, Xin Long wrote:
> sctp_assoc_set_id has already done the asoc_id check in the beginning
                  s/^^^^^^^^^^^^^^^^/does/
Very important to use the right tense here as otherwise it gives the
impression that the check was already made, which is not true.

> when processing dupcook, no need to do the same check before calling
                s/^^^^^^^/dupcookie/

other than this, LGTM, including the comment update.

  Marcelo

> it.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/associola.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index a9708da..ce2a3ec 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1181,12 +1181,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
>  			new->stream = NULL;
>  		}
>  
> -		if (!asoc->assoc_id) {
> -			/* get a new association id since we don't have one
> -			 * yet.
> -			 */
> -			sctp_assoc_set_id(asoc, GFP_ATOMIC);
> -		}
> +		/* get a new association id if we don't have one yet. */
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
