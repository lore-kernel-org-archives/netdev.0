From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] udp: Record RPS flow in socket operations
Date: Mon, 27 Oct 2014 11:50:38 -0700
Message-ID: <1414435838.32624.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414432875-23795-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:62700 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbaJ0Suk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 14:50:40 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so5985556pad.7
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 11:50:40 -0700 (PDT)
In-Reply-To: <1414432875-23795-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-27 at 11:01 -0700, Tom Herbert wrote:
> Add calls to sock_rps_record_flow for udp_sendmsg, udp_sendpage
> and udp_recvmsg. This enables RFS for connected UDP sockets.
> 
> Tested:

...

> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv4/udp.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index cd0db54..9a0d346 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -881,6 +881,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  	struct sk_buff *skb;
>  	struct ip_options_data opt_copy;
>  
> +	sock_rps_record_flow(sk);
> +
>  	if (len > 0xFFFF)
>  		return -EMSGSIZE;
>  
> @@ -1113,6 +1115,8 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
>  	struct udp_sock *up = udp_sk(sk);
>  	int ret;
>  
> +	sock_rps_record_flow(sk);
> +
>  	if (flags & MSG_SENDPAGE_NOTLAST)
>  		flags |= MSG_MORE;
>  
> @@ -1253,6 +1257,8 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  	int is_udplite = IS_UDPLITE(sk);
>  	bool slow;
>  
> +	sock_rps_record_flow(sk);
> +
>  	if (flags & MSG_ERRQUEUE)
>  		return ip_recv_error(sk, msg, len, addr_len);
>  

This patch is not needed.

All these paths go through af_inet.c and calls to sock_rps_record_flow()
are already done in inet_sendmsg(), inet_sendpage(), inet_recvmsg()

I wonder what you actually tested.
