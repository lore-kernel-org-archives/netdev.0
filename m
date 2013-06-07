From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 3/3] net: sctp: minor: remove variable in
 sctp_init_sock
Date: Fri, 7 Jun 2013 07:04:24 -0400
Message-ID: <20130607110424.GC3249@hmsreliant.think-freely.org>
References: <1370594106-25745-1-git-send-email-dborkman@redhat.com>
 <1370594106-25745-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59957 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486Ab3FGLEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 07:04:34 -0400
Content-Disposition: inline
In-Reply-To: <1370594106-25745-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 07, 2013 at 10:35:06AM +0200, Daniel Borkmann wrote:
> It's only used at this one time, so we could remove it as well.
> This is valid and also makes it more explicit/obvious that in case
> of error the sp->ep is NULL here, i.e. for the sctp_destroy_sock()
> check.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> ---
>  net/sctp/socket.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 3267534..e71d399 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -3862,7 +3862,6 @@ out:
>  SCTP_STATIC int sctp_init_sock(struct sock *sk)
>  {
>  	struct net *net = sock_net(sk);
> -	struct sctp_endpoint *ep;
>  	struct sctp_sock *sp;
>  
>  	SCTP_DEBUG_PRINTK("sctp_init_sock(sk: %p)\n", sk);
> @@ -3971,11 +3970,10 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
>  	 * change the data structure relationships, this may still
>  	 * be useful for storing pre-connect address information.
>  	 */
> -	ep = sctp_endpoint_new(sk, GFP_KERNEL);
> -	if (!ep)
> +	sp->ep = sctp_endpoint_new(sk, GFP_KERNEL);
> +	if (!sp->ep)
>  		return -ENOMEM;
>  
> -	sp->ep = ep;
>  	sp->hmac = NULL;
>  
>  	SCTP_DBG_OBJCNT_INC(sock);
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
