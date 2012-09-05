From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v3] ipv6: fix handling of blackhole and prohibit
 routes
Date: Wed, 05 Sep 2012 17:50:52 -0400 (EDT)
Message-ID: <20120905.175052.246018302031393962.davem@davemloft.net>
References: <50472379.10608@6wind.com>
	<1346847162-3558-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759614Ab2IEVux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 17:50:53 -0400
In-Reply-To: <1346847162-3558-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed,  5 Sep 2012 08:12:42 -0400

> When adding a blackhole or a prohibit route, they were handling like classic
> routes. Moreover, it was only possible to add this kind of routes by specifying
> an interface.
> 
> Bug already reported here:
>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=498498
> 
> Before the patch:
>   $ ip route add blackhole 2001::1/128
>   RTNETLINK answers: No such device
>   $ ip route add blackhole 2001::1/128 dev eth0
>   $ ip -6 route | grep 2001
>   2001::1 dev eth0  metric 1024
> 
> After:
>   $ ip route add blackhole 2001::1/128
>   $ ip -6 route | grep 2001
>   blackhole 2001::1 dev lo  metric 1024  error -22
> 
> v2: wrong patch
> v3: add a field fc_type in struct fib6_config to store RTN_* type
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I like this a lot more than your original patch, applied to net-next,
thanks.
