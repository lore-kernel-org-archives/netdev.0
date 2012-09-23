From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Sun, 23 Sep 2012 19:40:33 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209231930520.3904@nerf07.vanv.qr>
References: <1348242511.2669.635.camel@edumazet-glaptop> <20120921.122705.1344923255084267186.davem@davemloft.net> <alpine.LNX.2.01.1209231446170.9625@nerf07.vanv.qr> <20120923.121601.2244503178301624422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com,
	subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:59132 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290Ab2IWRke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2012 13:40:34 -0400
In-Reply-To: <20120923.121601.2244503178301624422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sunday 2012-09-23 18:16, David Miller wrote:
>> On Friday 2012-09-21 18:27, David Miller wrote:
>> 
>>>From: Eric Dumazet <eric.dumazet@gmail.com>
>>>Date: Fri, 21 Sep 2012 17:48:31 +0200
>>>
>>>> There is probably a reason why lo default MTU is 16436 ?
>>>
>>>That's what fit into L1 caches back in 1999
>> 
>> Would it make sense to automatically set lo's MTU on device
>> registration to the actual size of the L1 that the $running system
>> has?
>
>I think a fixed value of 64K would be a easiest, because another issue
>is that back in 1999 we didn't have GRO/GSO/etc.


Cache sizes, and an oddity.

L1 cache sizes have not increased ever since (the 2011 Intel i7-2600
has the same amount of L1 as a 1998ish AMD K6-2), and the Atom N450
even has less, namely 24d+32i, meaning a 13000ish MTU might be more
accurate for netbooks of this kind.

What would a MTU of 64K buy? Offloading seems pointless for the lo
device. There is no hardware to offload it to - well, the
machine already has the packet too.
