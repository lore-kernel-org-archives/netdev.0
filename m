From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 6/7] soreuseport: fast reuseport TCP socket
 selection
Date: Wed, 10 Feb 2016 06:02:35 -0500 (EST)
Message-ID: <20160210.060235.2264036197106612193.davem@davemloft.net>
References: <1455063542-18227-1-git-send-email-kraigatgoog@gmail.com>
	<1455063542-18227-7-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753635AbcBJLCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 06:02:38 -0500
In-Reply-To: <1455063542-18227-7-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue,  9 Feb 2016 19:19:01 -0500

> diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
> index 19913e9e09e0..1ec87f62bdd7 100644
> --- a/net/ipv6/inet6_hashtables.c
> +++ b/net/ipv6/inet6_hashtables.c
 ...
> @@ -283,7 +297,7 @@ int inet6_hash(struct sock *sk)
>  {
>  	if (sk->sk_state != TCP_CLOSE) {
>  		local_bh_disable();
> -		__inet_hash(sk, NULL);
> +		__inet_hash(sk, NULL, ipv6_rcv_saddr_equal);
>  		local_bh_enable();
>  	}
>  
> -- 
> 2.7.0.rc3.207.g0ac5344
> 

You cannot invoke 'm' code (net/ipv6/udp.c:ipv6_rcv_saddr_equal) from 'y'
code (net/ipv6/inet6_hashtables.c:inet6_hash).
