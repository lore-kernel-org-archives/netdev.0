From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-net] net: loopback: set default mtu to 64K
Date: Mon, 24 Sep 2012 16:38:46 -0400 (EDT)
Message-ID: <20120924.163846.351381312643475595.davem@davemloft.net>
References: <1348475339.26828.188.camel@edumazet-glaptop>
	<20120924.162442.1381532664983403691.davem@redhat.com>
	<1348518796.26828.1651.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757999Ab2IXUiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:38:50 -0400
In-Reply-To: <1348518796.26828.1651.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Sep 2012 22:33:16 +0200

> On Mon, 2012-09-24 at 16:24 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 24 Sep 2012 10:28:59 +0200
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > loopback current mtu of 16436 bytes allows no more than 3 MSS TCP
>> > segments per frame, or 48 Kbytes. Changing mtu to 64K allows TCP
>> > stack to build large frames and significantly reduces stack overhead.
>> > 
>> > Performance boost on bulk TCP transferts can be up to 30 %, partly
>> > because we now have one ACK message for two 64KB segments, and a lower
>> > probability of hitting /proc/sys/net/ipv4/tcp_reordering default limit.
>> > 
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> This gives a nice %13 improvement on my SPARC-T4 box as well.
>> 
>> Applied, thanks Eric.
> 
> the biggest increase is with
> 
> netperf -- -m 63K
> 
> I reach 50000 Mbytes/second

I tested with lmbench bw_tcp, which gives me about 1308 MB/sec.

And indeed that netperf command line gives superior numbers,
about 11747 MB/sec
