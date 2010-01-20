From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 4/9] net/sctp: Eliminate useless code
Date: Wed, 20 Jan 2010 13:10:10 -0500
Message-ID: <4B574702.4040602@hp.com>
References: <Pine.LNX.4.64.1001161657570.28745@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:17357 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899Ab0ATSKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 13:10:13 -0500
In-Reply-To: <Pine.LNX.4.64.1001161657570.28745@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> The variable newinet is initialized twice to the same (side effect-free)
> expression.  Drop one initialization.
> 
> A simplified version of the semantic match that finds this problem is:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @forall@
> idexpression *x;
> identifier f!=ERR_PTR;
> @@
> 
> x = f(...)
> ... when != x
> (
> x = f(...,<+...x...+>,...)
> |
> * x = f(...)
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>


> 
> ---
>  net/sctp/socket.c                   |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 67fdac9..f6d1e59 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6359,7 +6359,7 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
>  		    struct sctp_association *asoc)
>  {
>  	struct inet_sock *inet = inet_sk(sk);
> -	struct inet_sock *newinet = inet_sk(newsk);
> +	struct inet_sock *newinet;
>  
>  	newsk->sk_type = sk->sk_type;
>  	newsk->sk_bound_dev_if = sk->sk_bound_dev_if;
> 
