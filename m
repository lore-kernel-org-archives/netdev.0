From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] netem: fix rate extension and drop accounting
Date: Wed, 4 Jul 2012 00:04:43 +0200
Message-ID: <20120703220442.GC5064@nuttenaction>
References: <1341307524.2583.115.camel@edumazet-glaptop>
 <1341309257.2583.153.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Andreas Terzis <aterzis@google.com>,
	Mark Gordon <msg@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50367 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756518Ab2GCWEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 18:04:45 -0400
Content-Disposition: inline
In-Reply-To: <1341309257.2583.153.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2012-07-03 11:54:17 [+0200]:

>> commit 7bc0f28c7a0c (netem: rate extension) did wrong maths when packet
>> is enqueued while queue is not empty.
>> 
>> Result is unexpected cumulative delays
>> 
>> # tc qd add dev eth0 root est 1sec 4sec netem delay 200ms rate 100kbit
>> # ping -i 0.1 172.30.42.18
>> PING 172.30.42.18 (172.30.42.18) 56(84) bytes of data.
>> 64 bytes from 172.30.42.18: icmp_req=1 ttl=64 time=208 ms
>> 64 bytes from 172.30.42.18: icmp_req=2 ttl=64 time=424 ms
>> 64 bytes from 172.30.42.18: icmp_req=3 ttl=64 time=838 ms
>> 64 bytes from 172.30.42.18: icmp_req=4 ttl=64 time=1142 ms
>> 64 bytes from 172.30.42.18: icmp_req=5 ttl=64 time=1335 ms
>> 64 bytes from 172.30.42.18: icmp_req=6 ttl=64 time=1949 ms
>> 64 bytes from 172.30.42.18: icmp_req=7 ttl=64 time=2450 ms
>> 64 bytes from 172.30.42.18: icmp_req=8 ttl=64 time=2840 ms
>> 64 bytes from 172.30.42.18: icmp_req=9 ttl=64 time=3121 ms
>> 64 bytes from 172.30.42.18: icmp_req=10 ttl=64 time=3291 ms
>> 64 bytes from 172.30.42.18: icmp_req=11 ttl=64 time=3784 ms

Strange, we test the patch in detail. I will take a look ...
