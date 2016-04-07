From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 3/7] sctp: export some functions for sctp_diag
 in inet_diag
Date: Thu, 7 Apr 2016 15:17:16 -0300
Message-ID: <20160407181716.GE15005@localhost.localdomain>
References: <cover.1459829123.git.lucien.xin@gmail.com>
 <d16e3f12f689f28d8c3b62c7c2a15916177bd7c0.1459829123.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757091AbcDGSRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 14:17:20 -0400
Content-Disposition: inline
In-Reply-To: <d16e3f12f689f28d8c3b62c7c2a15916177bd7c0.1459829123.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2016 at 12:06:28PM +0800, Xin Long wrote:
> inet_diag_msg_common_fill is used to fill the diag msg common info,
> we need to use it in sctp_diag as well, so export it.
> 
> We also add inet_diag_get_handler() to access inet_diag_table in sctp
> diag.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/ipv4/inet_diag.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index bd591eb..29121a6 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -66,7 +66,13 @@ static void inet_diag_unlock_handler(const struct inet_diag_handler *handler)
>  	mutex_unlock(&inet_diag_table_mutex);
>  }
>  
> -static void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
> +struct inet_diag_handler *inet_diag_get_handler(int proto)

It needs to return it as const, as inet_diag_table is also declared as
const, so we don't loose the qualifier.

> +{
> +	return inet_diag_table[proto];
> +}
> +EXPORT_SYMBOL_GPL(inet_diag_get_handler);
> +
> +void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
>  {
>  	r->idiag_family = sk->sk_family;
>  
> @@ -89,6 +95,7 @@ static void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
>  	r->id.idiag_dst[0] = sk->sk_daddr;
>  	}
>  }
> +EXPORT_SYMBOL_GPL(inet_diag_msg_common_fill);
>  
>  static size_t inet_sk_attr_size(void)
>  {
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
