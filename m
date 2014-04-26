From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for
 /proc/net/ipv6_route
Date: Sat, 26 Apr 2014 00:11:34 -0400 (EDT)
Message-ID: <20140426.001134.778620720962127881.davem@davemloft.net>
References: <535918BC.5030708@fb.com>
	<20140425.160929.1031376209639331549.davem@davemloft.net>
	<535AC529.4030107@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: clm@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaDZELf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 00:11:35 -0400
In-Reply-To: <535AC529.4030107@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mason <clm@fb.com>
Date: Fri, 25 Apr 2014 16:27:21 -0400

> Ah ok, so the rtnl mutex can replace rcu_read_lock().  Will it end up
> blocking any traffic? (sorry, filesystem guys are a little slow)

It stops networking configuration operations.

BTW, this means that netlink based ipv6 route dumps can be
optimized similarly.  Because those code paths implicitly
hold the RTNL mutex.
