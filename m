From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 02/15] smc: establish new socket family
Date: Fri, 25 Nov 2016 20:47:13 -0500 (EST)
Message-ID: <20161125.204713.324066411863851415.davem@davemloft.net>
References: <20161124150645.90881-1-ubraun@linux.vnet.ibm.com>
        <20161124150645.90881-3-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752181AbcKZBrR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 20:47:17 -0500
In-Reply-To: <20161124150645.90881-3-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Thu, 24 Nov 2016 16:06:32 +0100

> +static struct sock *smc_sock_alloc(struct net *net, struct socket *sock)
> +{
> +	struct smc_sock *smc;
> +	struct sock *sk;
> +
> +	sk = sk_alloc(net, PF_SMC, GFP_KERNEL, &smc_proto, 0);
> +	if (!sk)
> +		return NULL;
> +
> +	sock_init_data(sock, sk); /* sets sk_refcnt to 1 */
> +	sk->sk_state = SMC_INIT;
> +	sk->sk_destruct = smc_destruct;
> +	sk->sk_protocol = SMCPROTO_SMC;
> +	sk_refcnt_debug_inc(sk);
> +
> +	smc = smc_sk(sk);
> +	smc->clcsock = NULL;
> +	smc->use_fallback = 0;

This is unnecessary, sk_alloc() clears out the memory for you.

> +static int smc_bind(struct socket *sock, struct sockaddr *uaddr,
> +		    int addr_len)
> +{
 ...
> +	smc->clcsock->sk->sk_reuse = sk->sk_reuse;
> +	rc = kernel_bind(smc->clcsock, uaddr, addr_len);

Is it valid to assume smc->clcsock is not NULL right here?

> +struct smc_sock {				/* smc sock container */
> +	struct sock		sk;
> +	struct socket		*clcsock;	/* internal tcp socket */
> +	u8			use_fallback : 1; /* fallback to tcp */
> +};

Please use 'bool' and true/false for 'use_fallback'.
