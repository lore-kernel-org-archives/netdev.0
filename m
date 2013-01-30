From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: Update MIB counters for drops
Date: Wed, 30 Jan 2013 15:31:15 -0800
Message-ID: <1359588675.30177.15.camel@edumazet-glaptop>
References: <1359586670-16072-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	niveditasinghvi@gmail.com
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f177.google.com ([209.85.213.177]:53247 "EHLO
	mail-ye0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756442Ab3A3XjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 18:39:14 -0500
Received: by mail-ye0-f177.google.com with SMTP id m14so421863yen.36
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 15:39:14 -0800 (PST)
In-Reply-To: <1359586670-16072-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-30 at 14:57 -0800, Vijay Subramanian wrote:
> This patch updates LINUX_MIB_LISTENDROPS and LINUX_MIB_LISTENOVERFLOWS in
> tcp_v4_conn_request() and tcp_v4_err(). tcp_v4_conn_request() in particular can
> drop SYNs for various reasons which are not currently tracked.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
> Ignored "line over 80 chars" warning for readability.
> 
>  net/ipv4/tcp_ipv4.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)


>  	case TCP_SYN_SENT:
> @@ -1491,8 +1492,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>  	 */
>  	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
>  		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
> -		if (!want_cookie)
> +		if (!want_cookie) {
> +			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
>  			goto drop;
> +		}

This should be done in tcp_syn_flood_action() for IPv4/IPv6
factorization.
