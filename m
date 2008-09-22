From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 15:47:30 -0700
Message-ID: <48D82082.7010803@hp.com>
References: <48C6C300.4050102@redhat.com>	<20080909.125934.150042096.davem@davemloft.net>	<20080922.034933.119934091.davem@davemloft.net>	<20080922.040912.193700258.davem@davemloft.net>	<20080922203042.GY25711@one.firstfloor.org> <48D81A95.5080207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:9765 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908AbYIVWro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 18:47:44 -0400
In-Reply-To: <48D81A95.5080207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Indeed.  Setting tcp_delack_min to 0 completely eliminated the undesired 
> latencies, though of course that would be a bit dangerous with naive 
> apps talking across the network. 

What did it do to the packets per second or per unit of work?  Depending 
on the nature of the race between the ACK returning from the remote and 
the application pushing more bytes into the socket, I'd think that 
setting the delayed ack timer to zero could result in more traffic on 
the network (those bare ACKs) than simply setting TCP_NODELAY at the source.

And since with small packets and/or copy avoidance an ACK is 
(handwaving) just as many CPU cycles at either end as a data segment 
that also means a bump in CPU utilization.

rick jones
