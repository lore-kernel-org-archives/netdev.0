From: David Miller <davem@davemloft.net>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 03 Dec 2013 16:50:34 -0500 (EST)
Message-ID: <20131203.165034.1085515763685633822.davem@davemloft.net>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, joseph.gasparakis@intel.com,
	hkchu@google.com, ogerlitz@mellanox.com, edumazet@google.com,
	ast@plumgrid.com, pshelar@nicira.com, netdev@vger.kernel.org
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656Ab3LCVuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 16:50:39 -0500
In-Reply-To: <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Tue, 3 Dec 2013 23:36:50 +0200

> I also thought that under veth there's contention point which could
> explain why packets are dropped, but haven't found it.

At this point I would use drop monitor to figure out in what context
packets are being dropped on the floor.  There are scripts provided
with the perf tool to utilize it.

I suspect what you will find is that either the cpu is at %100, or
sporadic events where GRO is not performed is killing the stream.
