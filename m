From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] tcp: heed result of security_inet_conn_request()
 in tcp_v6_conn_request()
Date: Sun, 24 Jun 2012 09:36:57 +0200
Message-ID: <1340523417.23933.4.camel@edumazet-glaptop>
References: <1340515324-2152-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61316 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801Ab2FXHhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 03:37:01 -0400
Received: by weyu7 with SMTP id u7so2101956wey.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 00:37:00 -0700 (PDT)
In-Reply-To: <1340515324-2152-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-06-24 at 01:22 -0400, Neal Cardwell wrote:
> If security_inet_conn_request() returns non-zero then TCP/IPv6 should
> drop the request, just as in TCP/IPv4 and DCCP in both IPv4 and IPv6.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv6/tcp_ipv6.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 3a9aec2..9df64a5 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1212,7 +1212,8 @@ have_isn:
>  	tcp_rsk(req)->snt_isn = isn;
>  	tcp_rsk(req)->snt_synack = tcp_time_stamp;
>  
> -	security_inet_conn_request(sk, skb, req);
> +	if (security_inet_conn_request(sk, skb, req))
> +		goto drop_and_release;
>  
>  	if (tcp_v6_send_synack(sk, req,
>  			       (struct request_values *)&tmp_ext,

Acked-by: Eric Dumazet <edumazet@google.com>
