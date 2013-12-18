From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] sctp: remove the never used 'return' and,
 redundant 'break'
Date: Wed, 18 Dec 2013 09:06:54 -0500
Message-ID: <20131218140654.GB10471@neilslaptop.think-freely.org>
References: <52B168E0.1060108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40820 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab3LROHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:07:10 -0500
Content-Disposition: inline
In-Reply-To: <52B168E0.1060108@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 05:20:32PM +0800, Wang Weidong wrote:
> In switch() had do return, and never use the 'return NULL'. The
> 'break' after return or goto has no effect. Remove it.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/input.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 2a192a7..c956dc9 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -1120,15 +1120,10 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
>  	case SCTP_CID_INIT:
>  	case SCTP_CID_INIT_ACK:
>  		return __sctp_rcv_init_lookup(net, skb, laddr, transportp);
> -		break;
>  
>  	default:
>  		return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
> -		break;
>  	}
> -
> -
> -	return NULL;
>  }
>  
>  /* Lookup an association for an inbound skb. */
> -- 
> 1.7.12
> 
> 
> 

If you're going to do this, it seems like you may just as well convert the
switch to be if (ch->type && ch->type <= SCTP_CID_INIT_ACK) {...} else {...}


That seems like it would be more readable to me.

Neil
