From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: remove useless err from sctp_association_init
Date: Mon, 20 Mar 2017 10:56:37 -0400
Message-ID: <20170320145637.GB7855@hmswarspite.think-freely.org>
References: <82209fcc4742baa1c4855af7e54b88177e9d0537.1490004028.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34909 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754481AbdCTO6p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 10:58:45 -0400
Content-Disposition: inline
In-Reply-To: <82209fcc4742baa1c4855af7e54b88177e9d0537.1490004028.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 06:00:28PM +0800, Xin Long wrote:
> This patch is to remove the unnecessary temporary variable 'err' from
> sctp_association_init.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/associola.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 2a6835b..0439a1a 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -71,9 +71,8 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>  {
>  	struct net *net = sock_net(sk);
>  	struct sctp_sock *sp;
> -	int i;
>  	sctp_paramhdr_t *p;
> -	int err;
> +	int i;
>  
>  	/* Retrieve the SCTP per socket area.  */
>  	sp = sctp_sk((struct sock *)sk);
> @@ -264,8 +263,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
>  
>  	/* AUTH related initializations */
>  	INIT_LIST_HEAD(&asoc->endpoint_shared_keys);
> -	err = sctp_auth_asoc_copy_shkeys(ep, asoc, gfp);
> -	if (err)
> +	if (sctp_auth_asoc_copy_shkeys(ep, asoc, gfp))
>  		goto fail_init;
>  
>  	asoc->active_key_id = ep->active_key_id;
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
