From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: remove an unnecessary check from
 sctp_endpoint_destroy
Date: Fri, 30 Jun 2017 13:51:26 -0300
Message-ID: <20170630165126.GN18138@localhost.localdomain>
References: <9a583ea8d84ee913f4c7ba1571e6cfeb24c9ef8b.1498728486.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4881 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751657AbdF3Qva (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 12:51:30 -0400
Content-Disposition: inline
In-Reply-To: <9a583ea8d84ee913f4c7ba1571e6cfeb24c9ef8b.1498728486.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 05:28:06PM +0800, Xin Long wrote:
> ep->base.sk gets it's value since sctp_endpoint_new, nowhere
> will change it. So there's no need to check if it's null, as
> it can never be null.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/endpointola.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 3dcd0ec..7772ca4 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -268,16 +268,14 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>  
>  	memset(ep->secret_key, 0, sizeof(ep->secret_key));
>  
> -	/* Give up our hold on the sock. */
>  	sk = ep->base.sk;
> -	if (sk != NULL) {
> -		/* Remove and free the port */
> -		if (sctp_sk(sk)->bind_hash)
> -			sctp_put_port(sk);
> +	/* Remove and free the port */
> +	if (sctp_sk(sk)->bind_hash)
> +		sctp_put_port(sk);
>  
> -		sctp_sk(sk)->ep = NULL;
> -		sock_put(sk);
> -	}
> +	sctp_sk(sk)->ep = NULL;
> +	/* Give up our hold on the sock */
> +	sock_put(sk);
>  
>  	kfree(ep);
>  	SCTP_DBG_OBJCNT_DEC(ep);
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
