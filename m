From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: slight optimization for vlan
Date: Tue, 04 Mar 2014 16:24:36 -0500 (EST)
Message-ID: <20140304.162436.1110716815887069100.davem@davemloft.net>
References: <5315AF42.8030905@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, joe@perches.com, julia.lawall@lip6.fr,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756070AbaCDVYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:24:39 -0500
In-Reply-To: <5315AF42.8030905@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 4 Mar 2014 18:47:30 +0800

> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and
> can be used when each argument is an array within a structure that
> contains at least two bytes of data beyond the array, so it is safe
> to use it for vlan.
> 
> On a simple test by iperf, it reduces the CPU %system time from 14% to 12%.
> 
> According Joe's suggestion, maybe it'd be faster to add an unlikely to
> the test for PCKET_OTHERHOST, so I add it and see whether the performance
> could be better, but the differences is so small and negligible, maybe my
> test case is not effective enough, but I still add the unlikely and wait to
> hear more opinions.:)
> 
> Cc: Joe Perches <joe@perches.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

I agree with Joe that we should only use the optimized routine in
performance critical paths.
