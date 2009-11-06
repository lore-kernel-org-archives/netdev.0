From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next2.6] ipv6: avoid dev_hold()/dev_put() in rawv6_bind()
Date: Fri, 06 Nov 2009 11:48:46 -0500
Message-ID: <4AF4536E.7090803@hp.com>
References: <4AF40022.6050100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:34703 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759446AbZKFQtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 11:49:04 -0500
In-Reply-To: <4AF40022.6050100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote: 
> @@ -257,6 +257,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	if (sk->sk_state != TCP_CLOSE)
>  		goto out;
>  
> +	rcu_read_unlock();
>  	/* Check if the address belongs to the host. */
>  	if (addr_type != IPV6_ADDR_ANY) {
>  		struct net_device *dev = NULL;

This was supposed to be rcu_read_lock(), right?

-Brian
