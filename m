From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: move sk_rx_dst_set call after
 tcp_create_openreq_child()
Date: Sun, 19 Aug 2012 12:45:23 +0200
Message-ID: <1345373123.5158.71.camel@edumazet-glaptop>
References: <1345348619-19327-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:40861 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab2HSKp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 06:45:28 -0400
Received: by wgbfm10 with SMTP id fm10so2536567wgb.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 03:45:27 -0700 (PDT)
In-Reply-To: <1345348619-19327-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-08-18 at 23:56 -0400, Neal Cardwell wrote:
> This commit removes the sk_rx_dst_set calls from
> tcp_create_openreq_child(), because at that point the icsk_af_ops
> field of ipv6_mapped TCP sockets has not been set to its proper final
> value.
> 
> Instead, to make sure we get the right sk_rx_dst_set variant
> appropriate for the address family of the new connection, we have
> tcp_v{4,6}_syn_recv_sock() directly call the appropriate function
> shortly after the call to tcp_create_openreq_child() returns.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Reported-by: Artem Savkov <artem.savkov@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---


>  		 * copy any s_data_payload stored at the original socket.
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index bb9ce2b..492c2d9 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -81,6 +81,8 @@ static void	__tcp_v6_send_check(struct sk_buff *skb,
>  				    const struct in6_addr *saddr,
>  				    const struct in6_addr *daddr);
>  
> +static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
> +


Hi Neal, thanks for taking care of this.

Could you move inet6_sk_rx_dst_set() definition to avoid this forward ?
