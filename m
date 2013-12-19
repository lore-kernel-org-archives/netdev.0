From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next v2] sctp: remove the never used 'return' and
 redundant 'break'
Date: Thu, 19 Dec 2013 07:12:50 -0500
Message-ID: <20131219121250.GA18197@hmsreliant.think-freely.org>
References: <52B168E0.1060108@huawei.com>
 <52B253C2.8070407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58007 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902Ab3LSMNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 07:13:01 -0500
Content-Disposition: inline
In-Reply-To: <52B253C2.8070407@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 10:02:42AM +0800, Wang Weidong wrote:
> In switch() had do return, and never use the 'return NULL'. The
> 'break' after return or goto has no effect. Remove it.
> 
> v2: make it more readable as suggested by Neil.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/input.c | 13 ++-----------
>  1 file changed, 2 insertions(+), 11 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 042ec6c..476bc8d 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -1119,19 +1119,10 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
>  		return NULL;
>  
>  	/* If this is INIT/INIT-ACK look inside the chunk too. */
> -	switch (ch->type) {
> -	case SCTP_CID_INIT:
> -	case SCTP_CID_INIT_ACK:
> +	if (ch->type == SCTP_CID_INIT || ch->type == SCTP_CID_INIT_ACK)
>  		return __sctp_rcv_init_lookup(net, skb, laddr, transportp);
> -		break;
>  
> -	default:
> -		return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
> -		break;
> -	}
> -
> -
> -	return NULL;
> +	return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
>  }
>  
>  /* Lookup an association for an inbound skb. */
> -- 
> 1.7.12
> 
> 
> 
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
