From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Netchannels: alternative TCP/IP stack?
Date: Tue, 13 Jun 2006 21:33:21 +0400
Message-ID: <20060613173321.GA648@2ka.mipt.ru>
References: <20060608171555.GA10273@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40079 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750742AbWFMRdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 13:33:24 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060608171555.GA10273@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, developers.

I've implemented simple rfc793 TCP/IP stack, which is currently tested
in userspace through packet socket. After ISO (~650Mb) transfer over 
gigabit ethernet between two Linux boxes, file was not corrupted.

I would even say that stack is really trivial (1800 lines of code, 42K
of sources where TCP state machine takes about 12K), but it includes:
* routing table for src/dst IP and MAC addresses (O(n) access).
	It includes static destination routing and ARP cache.
	No dynamic ARP probes.
* socket-like (actually netchannel-like) interface for data reading.
* ethernet sending/receiving support.
* IP sending/receiving support.
* TCP (rfc793) state machine implementation.
* UDP code (not tested).

Current code does not have options and TCP extensions, ack generation
does not use any heueristics, no congestion control, no prediction
(although I have some doubts about that idea), no ICMP. 
Sending was not tested yet.
Next option in agenda is to check various loss and reordering
issues. Then I plan to implement PAWS and timestamp TCP option.
MSS option would be usefull too.

I want to run various tests with congestions to collect some statistic
about generic TCP/IP behaviour, so I would like to ask
how much it will be frowned upon if I will use that simple stack for
netchannels (I plan to use only alternative TCP part with generic Linux
routing tables, IP and ethernet processing and so on)
and if miracle happens (it happens sometimes) and results will be better
than it is now [1] (it is planned if paid job will not get all the time)
and I will start pushing it upstream?
Or is it better to just make lobotomy right now?

1. Netchannel benchmarks vs. socket code.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

Thank you.

-- 
	Evgeniy Polyakov
