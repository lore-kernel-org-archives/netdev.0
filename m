From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ping: Return EAFNOSUPPORT when appropriate.
Date: Wed, 04 Mar 2015 15:47:23 -0500 (EST)
Message-ID: <20150304.154723.1071370525446900440.davem@davemloft.net>
References: <1425392176-29114-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbbCDUr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:47:27 -0500
In-Reply-To: <1425392176-29114-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue,  3 Mar 2015 23:16:16 +0900

> 1. For an IPv4 ping socket, ping_check_bind_addr does not check
>    the family of the socket address that's passed in. Instead,
>    make it behave like inet_bind, which enforces either that the
>    address family is AF_INET, or that the family is AF_UNSPEC and
>    the address is 0.0.0.0.
> 2. For an IPv6 ping socket, ping_check_bind_addr returns EINVAL
>    if the socket family is not AF_INET6. Return EAFNOSUPPORT
>    instead, for consistency with inet6_bind.
> 3. Make ping_v4_sendmsg and ping_v6_sendmsg return EAFNOSUPPORT
>    instead of EINVAL if an incorrect socket address structure is
>    passed in.
> 4. Make IPv6 ping sockets be IPv6-only. The code does not support
>    IPv4, and it cannot easily be made to support IPv4 because
>    the protocol numbers for ICMP and ICMPv6 are different. This
>    makes connect(::ffff:192.0.2.1) fail with EAFNOSUPPORT instead
>    of making the socket unusable.
> 
> Among other things, this fixes an oops that can be triggered by:
> 
>     int s = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
>     struct sockaddr_in6 sin6 = {
>         .sin6_family = AF_INET6,
>         .sin6_addr = in6addr_any,
>     };
>     bind(s, (struct sockaddr *) &sin6, sizeof(sin6));
> 
> Change-Id: If06ca86d9f1e4593c0d6df174caca3487c57a241
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied and queued up for -stable, thanks.
