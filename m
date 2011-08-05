From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: check for IPv4 mapped addresses when connecting
 IPv6 sockets
Date: Fri, 05 Aug 2011 03:57:04 -0700 (PDT)
Message-ID: <20110805.035704.1083062407751815748.davem@davemloft.net>
References: <20110804075506.62225813270B@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com
To: makc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab1HEK5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 06:57:08 -0400
In-Reply-To: <20110804075506.62225813270B@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Matveev <makc@redhat.com>
Date: Thu, 4 Aug 2011 17:42:44 +1000

> When support for binding to 'mapped INADDR_ANY (::ffff.0.0.0.0)' was added
> in 0f8d3c7ac3693d7b6c731bf2159273a59bf70e12 the rest of the code
> wasn't told so now it's possible to bind IPv6 datagram socket to
> ::ffff.0.0.0.0, connect it to another IPv4 address and it will all
> work except for getsockhame() which does not return the local address
> as expected.
> 
> To give getsockname() something to work with check for 'mapped INADDR_ANY'
> when connecting and update the in-core source addresses appropriately.
> 
> Signed-off-by: Max Matveev <makc@redhat.com>

Applied, but I had to fixup some trailing whitespace:

> @@ -102,10 +107,12 @@ ipv4_connected:
>  
>  		ipv6_addr_set_v4mapped(inet->inet_daddr, &np->daddr);
>  
> -		if (ipv6_addr_any(&np->saddr))
> +		if (ipv6_addr_any(&np->saddr) ||
> +		    ipv6_mapped_addr_any(&np->saddr))
>  			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
>  
> -		if (ipv6_addr_any(&np->rcv_saddr)) {
> +		if (ipv6_addr_any(&np->rcv_saddr) || 
						    ^^

there.
