From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix handling of throw routes
Date: Fri, 07 Sep 2012 14:18:08 -0400 (EDT)
Message-ID: <20120907.141808.933339383624986735.davem@davemloft.net>
References: <5048A374.60005@6wind.com>
	<1346946815-3094-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markus.stenberg@iki.fi,
	eric.dumazet@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab2IGSSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 14:18:10 -0400
In-Reply-To: <1346946815-3094-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  6 Sep 2012 11:53:35 -0400

> It's the same problem that previous fix about blackhole and prohibit routes.
> 
> When adding a throw route, it was handled like a classic route.
> Moreover, it was only possible to add this kind of routes by specifying
> an interface.
> 
> Before the patch:
>   $ ip route add throw 2001::2/128
>   RTNETLINK answers: No such device
>   $ ip route add throw 2001::2/128 dev eth0
>   $ ip -6 route | grep 2001::2
>   2001::2 dev eth0  metric 1024
> 
> After:
>   $ ip route add throw 2001::2/128
>   $ ip -6 route | grep 2001::2
>   throw 2001::2 dev lo  metric 1024  error -11
> 
> Reported-by: Markus Stenberg <markus.stenberg@iki.fi>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.

See how easy this was to implement via ->rtm_type? :-)
