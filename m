From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: use inet_recvmsg to support sctp RFS well
Date: Fri, 22 Jul 2016 10:34:04 -0300
Message-ID: <20160722133404.GE9950@localhost.localdomain>
References: <75f49fcd6f30e7ec41dc0f8e39983a9579386e49.1469193942.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754124AbcGVNeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 09:34:09 -0400
Content-Disposition: inline
In-Reply-To: <75f49fcd6f30e7ec41dc0f8e39983a9579386e49.1469193942.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 22, 2016 at 09:25:42PM +0800, Xin Long wrote:
> Commit 486bdee0134c ("sctp: add support for RPS and RFS")
> saves skb->hash into sk->sk_rxhash so that the inet_* can
> record it to flow table.
> 
> But sctp uses sock_common_recvmsg as .recvmsg instead
> of inet_recvmsg, sock_common_recvmsg doesn't invoke
> sock_rps_record_flow to record the flow. It may cause
> that the receiver has no chances to record the flow if
> it doesn't send msg or poll the socket.
> 
> So this patch fixes it by using inet_recvmsg as .recvmsg
> in sctp.
> 
> Fixes: 486bdee0134c ("sctp: add support for RPS and RFS")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Thanks

> ---
>  net/sctp/ipv6.c     | 2 +-
>  net/sctp/protocol.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index ae6f1a2..98c383c 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -954,7 +954,7 @@ static const struct proto_ops inet6_seqpacket_ops = {
>  	.setsockopt	   = sock_common_setsockopt,
>  	.getsockopt	   = sock_common_getsockopt,
>  	.sendmsg	   = inet_sendmsg,
> -	.recvmsg	   = sock_common_recvmsg,
> +	.recvmsg	   = inet_recvmsg,
>  	.mmap		   = sock_no_mmap,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt = compat_sock_common_setsockopt,
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 1adb927..7b523e3 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1028,7 +1028,7 @@ static const struct proto_ops inet_seqpacket_ops = {
>  	.setsockopt	   = sock_common_setsockopt, /* IP_SOL IP_OPTION is a problem */
>  	.getsockopt	   = sock_common_getsockopt,
>  	.sendmsg	   = inet_sendmsg,
> -	.recvmsg	   = sock_common_recvmsg,
> +	.recvmsg	   = inet_recvmsg,
>  	.mmap		   = sock_no_mmap,
>  	.sendpage	   = sock_no_sendpage,
>  #ifdef CONFIG_COMPAT
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
