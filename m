From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: reduce percpu needs for icmpv6msg mibs
Date: Mon, 14 Nov 2011 00:12:44 -0500 (EST)
Message-ID: <20111114.001244.386130843572045582.davem@davemloft.net>
References: <1321183444.17837.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab1KNFMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 00:12:47 -0500
In-Reply-To: <1321183444.17837.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 13 Nov 2011 12:24:04 +0100

> Reading /proc/net/snmp6 on a machine with a lot of cpus is very
> expensive (can be ~88000 us).
> 
> This is because ICMPV6MSG MIB uses 4096 bytes per cpu, and folding
> values for all possible cpus can read 16 Mbytes of memory (32MBytes on
> non x86 arches)
> 
> ICMP messages are not considered as fast path on a typical server, and
> eventually few cpus handle them anyway. We can afford an atomic
> operation instead of using percpu data.
> 
> This saves 4096 bytes per cpu and per network namespace.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
