From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Removed unnecessary assignments , gotos and goto labels
Date: Thu, 05 May 2011 11:00:36 -0700 (PDT)
Message-ID: <20110505.110036.115954748.davem@davemloft.net>
References: <1304187809-7887-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sasikanth.v19@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35157
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755015Ab1EESBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 14:01:08 -0400
In-Reply-To: <1304187809-7887-1-git-send-email-sasikanth.v19@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasikanth V <sasikanth.v19@gmail.com>
Date: Sat, 30 Apr 2011 23:53:29 +0530

> @@ -1779,15 +1770,15 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
>  	sll->sll_ifindex = po->ifindex;
>  	sll->sll_protocol = po->num;
>  	sll->sll_pkttype = 0;
> +	sll->sll_hatype = 0;	
> +	sll->sll_halen = 0;
> +
>  	rcu_read_lock();
>  	dev = dev_get_by_index_rcu(sock_net(sk), po->ifindex);
>  	if (dev) {
>  		sll->sll_hatype = dev->type;
>  		sll->sll_halen = dev->addr_len;
>  		memcpy(sll->sll_addr, dev->dev_addr, dev->addr_len);
> -	} else {
> -		sll->sll_hatype = 0;	/* Bad: we have no ARPHRD_UNSPEC */
> -		sll->sll_halen = 0;
>  	}
>  	rcu_read_unlock();

This is completely bogus.

In the dev != NULL case, we'll now write to sll_hatype and sll_halen
twice, which is less inefficient than making sure we write to these
fields only one.

And outside of this part, I really don't like the cleanups you made
here, and they don't improve the code in any way in my eyes.

Sorry.
