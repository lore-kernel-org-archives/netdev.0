From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 18:57:42 -0400
Message-ID: <48D822E6.6070309@redhat.com>
References: <48C6C300.4050102@redhat.com>	<20080909.125934.150042096.davem@davemloft.net>	<20080922.034933.119934091.davem@davemloft.net>	<20080922.040912.193700258.davem@davemloft.net>	<20080922203042.GY25711@one.firstfloor.org> <48D81A95.5080207@redhat.com> <48D82082.7010803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39317 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297AbYIVW5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 18:57:20 -0400
In-Reply-To: <48D82082.7010803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
>> Indeed.  Setting tcp_delack_min to 0 completely eliminated the 
>> undesired latencies, though of course that would be a bit dangerous 
>> with naive apps talking across the network. 
> 
> What did it do to the packets per second or per unit of work?  Depending 
> on the nature of the race between the ACK returning from the remote and 
> the application pushing more bytes into the socket, I'd think that 
> setting the delayed ack timer to zero could result in more traffic on 
> the network (those bare ACKs) than simply setting TCP_NODELAY at the 
> source.
> 
> And since with small packets and/or copy avoidance an ACK is 
> (handwaving) just as many CPU cycles at either end as a data segment 
> that also means a bump in CPU utilization.
> 
> rick jones

I never saw performance go down, but I was always using low latency/high 
bandwidth loopback or LAN connection, with only one socket per CPU.

I agree though, that turning this off is suboptimal.  I'm going to pursue 
David's idea of making delack_min and ato_min dynamically calculated by the kernel.

-- Chris
