From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] X25: Replace BKL in sockopts calls
Date: Sun, 09 May 2010 18:46:58 -0700 (PDT)
Message-ID: <20100509.184658.170123822.davem@davemloft.net>
References: <1273409123.2727.387.camel@ibex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754844Ab0EJBqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 May 2010 21:46:50 -0400
In-Reply-To: <1273409123.2727.387.camel@ibex>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Sun, 09 May 2010 22:45:23 +1000

> @@ -465,20 +464,20 @@ static int x25_setsockopt(struct socket *sock, int level, int optname,
>  	if (get_user(opt, (int __user *)optval))
>  		goto out;
>  
> +	lock_sock(sk);
>  	x25_sk(sk)->qbitincl = !!opt;
> +	release_sock(sk);

This is completely bogus.

A store is always atomic on an SMP system, and "opt" is in a local variable
rather than being computed based upon some memory values.

There is no reason to require locking for this operation.
