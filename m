From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ip: fix mc_loop checks for tunnels with
 multicast outer addresses
Date: Sun, 03 Jan 2010 21:58:55 -0800 (PST)
Message-ID: <20100103.215855.267134875.davem@davemloft.net>
References: <200912302201.37735.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60555
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753266Ab0ADF6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:58:51 -0500
In-Reply-To: <200912302201.37735.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed, 30 Dec 2009 22:01:37 +0200

> +	switch (sk->sk_family) {
> +	case AF_INET:
> +		return inet_sk(sk)->mc_loop;
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +	case AF_INET6:
> +		return inet6_sk(sk)->mc_loop;
> +	}
> +#endif
> +	__WARN();
> +	return 1;
> +}
> +

This won't compile with IPV6 disabled.  Switch closing brace is
erroneously inside of the ifdef test.

