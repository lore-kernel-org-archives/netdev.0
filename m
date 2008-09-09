From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 01:56:12 -0400
Message-ID: <48C60FFC.8090109@redhat.com>
References: <48C59F75.6030504@redhat.com>	<48C5A9A9.9040503@hp.com>	<48C6052D.2080203@redhat.com> <20080908.221742.02572583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51431 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165AbYIIF6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 01:58:16 -0400
In-Reply-To: <20080908.221742.02572583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Chris Snook <csnook@redhat.com>
> Date: Tue, 09 Sep 2008 01:10:05 -0400
> 
>> This is open to debate, but there are certainly a great many apps
>> doing a great deal of very important business that are subject to
>> this problem to some degree.
> 
> Let's be frank and be honest that we're talking about message passing
> financial service applications.

Mostly.

> And I specifically know that the problem they run into is that the
> congestion window doesn't open up because of Nagle _AND_ the fact that
> congestion control is done using packet counts rather that data byte
> totals.  So if you send lots of small stuff, the window doesn't open.
> Nagle just makes this problem worse, rather than create it.
> 
> And we have a workaround for them, which is a combination of the
> tcp_slow_start_after_idle sysctl in combination with route metrics
> specifying the initial congestion window value to use.
> 
> I specifically added that sysctl for this specific situation.

That's not the problem I'm talking about here.  The problem I'm seeing 
is that if your burst of messages is too small to fill the MTU, the 
network stack will just sit there and stare at you for precisely 40 ms 
(an eternity for a financial app) before transmitting.  Andi may be 
correct that it's actually the delayed ACK we're seeing, but I can't 
figure out where that 40 ms magic number is coming from.

The easiest way to see the problem is to open a TCP socket to an echo 
daemon on loopback, make a bunch of small writes totaling less than your 
loopback MTU (accounting for overhead), and see how long it takes to get 
your echoes.  You can probably do this with netcat, though I haven't 
tried.  People don't expect loopback to have 40 ms latency when the box 
is lightly loaded, so they'd really like to tweak that down when it's 
hurting them.

-- Chris
