From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 15:02:29 -0700
Message-ID: <20070712150229.7a841c4d@freepuppy.rosehill.hemminger.net>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
	<20070712.023710.36923635.davem@davemloft.net>
	<20070712.225950.12335719.noboru.obata.ar@hitachi.com>
	<20070712.132448.115910193.davem@davemloft.net>
	<20070712141203.7350429a@freepuppy.rosehill.hemminger.net>
	<46969CA9.8030406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: noboru.obata.ar@hitachi.com, David Miller <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42958 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753856AbXGLWCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 18:02:45 -0400
In-Reply-To: <46969CA9.8030406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007 14:27:05 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> > One question is why the RTO gets so large that it limits failover?
> > 
> > If Linux TCP is working correctly,  RTO should be srtt + 2*rttvar
> > 
> > So either there is a huge srtt or variance, or something is going
> > wrong with RTT estimation.  Given some reasonable maximums of
> > Srtt = 500ms and rttvar = 250ms, that would cause RTO to be 1second.
> 
> I suspect that what is happening here is that a link goes down in a 
> trunk somewhere for some number of seconds, resulting in a given TCP 
> segment being retransmitted several times, with the doubling of the RTO 
> each time.
> 
> rick jones

So the problem is that RTO can grows to be twice the failover detection
time.  So back to the original mail, the scenario has a switch with failover
detection of 20seconds.  Worst case TCP RTO could grow to 40 seconds.

Going back in archive to original mail:

> Background
> ==========
> 
> When designing a TCP/IP based network system on failover-capable
> network devices, people want to set timeouts hierarchically in
> three layers, network device layer, TCP layer, and application
> layer (bottom-up order), such that:
> 
> 1. Network device layer detects a failure first and switch to a
>    backup device (say, in 20sec).
> 
> 2. TCP layer timeout & retransmission comes next, _hopefully_
>    before the application layer timeout.
> 
> 3. Application layer detects a network failure last (by, say,
>    30sec timeout) and may trigger a system-level failover.

Sounds like the solution is to make the switch failover detection faster.
If you get switch failover down to 5sec then TCP RTO shouldn't be bigger
than 10sec, and application will survive.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
