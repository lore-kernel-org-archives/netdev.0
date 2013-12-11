From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: remove redundant null check on asoc
Date: Wed, 11 Dec 2013 07:09:36 -0500
Message-ID: <20131211120936.GA24339@hmsreliant.think-freely.org>
References: <52A82566.1050601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37467 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab3LKMJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 07:09:51 -0500
Content-Disposition: inline
In-Reply-To: <52A82566.1050601@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 04:42:14PM +0800, Wang Weidong wrote:
> In sctp_err_lookup, goto out while the asoc is not NULL, so remove the
> check NULL. Also, in sctp_err_finish which called by sctp_v4_err and
> sctp_v6_err, they pass asoc to sctp_err_finish while the asoc is not
> NULL, so remove the check.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/input.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 6603853..2a192a7 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -536,8 +536,7 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
>  	return sk;
>  
>  out:
> -	if (asoc)
> -		sctp_association_put(asoc);
> +	sctp_association_put(asoc);
>  	return NULL;
>  }
>  
> @@ -545,8 +544,7 @@ out:
>  void sctp_err_finish(struct sock *sk, struct sctp_association *asoc)
>  {
>  	sctp_bh_unlock_sock(sk);
> -	if (asoc)
> -		sctp_association_put(asoc);
> +	sctp_association_put(asoc);
>  }
>  
>  /*
> -- 
> 1.7.12
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Seems reasonable
Acked-by: Neil Horman <nhorman@tuxdriver.com>
