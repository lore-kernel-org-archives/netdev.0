From: David Miller <davem@davemloft.net>
Subject: Re: Bad behaviour when unintentionally mixing ipv4 and ipv6
 addresses
Date: Wed, 01 Jun 2011 21:03:59 -0700 (PDT)
Message-ID: <20110601.210359.2079286191194442010.davem@davemloft.net>
References: <20110525155918.GA27869@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, max@suse.de
To: meissner@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928Ab1FBEEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 00:04:04 -0400
In-Reply-To: <20110525155918.GA27869@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcus Meissner <meissner@suse.de>
Date: Wed, 25 May 2011 17:59:18 +0200

> @@ -465,6 +465,9 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  	if (addr_len < sizeof(struct sockaddr_in))
>  		goto out;
>  
> +	if (addr->sin_family != AF_INET)
> +		goto out;
> +
>  	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);

Since we haven't been validating the sin_family field for 18+ years, the
chance to break some applications is very real.

But I think it's more important to fix this (and force any broken apps
to set sin_family correctly).  So I will apply this, thanks.
