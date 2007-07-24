From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Tue, 24 Jul 2007 22:30:56 +0900 (JST)
Message-ID: <20070724.223056.132849806.noboru.obata.ar@hitachi.com>
References: <46969CA9.8030406@hp.com>
    <20070712150229.7a841c4d@freepuppy.rosehill.hemminger.net>
    <4696AAD2.9030405@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.hitachi.co.jp ([133.145.228.5]:50271 "EHLO
	mail4.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038AbXGXNbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 09:31:00 -0400
Received: from mlsv9.hitachi.co.jp (unknown [133.144.234.166])
	by mail4.hitachi.co.jp (Postfix) with ESMTP id 83D2433CC6
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 22:30:58 +0900 (JST)
In-Reply-To: <4696AAD2.9030405@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 15:27:30 -0700

> > So the problem is that RTO can grows to be twice the failover detection
> > time.  So back to the original mail, the scenario has a switch with failover
> > detection of 20seconds.  Worst case TCP RTO could grow to 40 seconds.
> > 
> > Going back in archive to original mail:
> > 
> > 
> >>Background
> >>==========
> >>
> >>When designing a TCP/IP based network system on failover-capable
> >>network devices, people want to set timeouts hierarchically in
> >>three layers, network device layer, TCP layer, and application
> >>layer (bottom-up order), such that:
> >>
> >>1. Network device layer detects a failure first and switch to a
> >>   backup device (say, in 20sec).
> >>
> >>2. TCP layer timeout & retransmission comes next, _hopefully_
> >>   before the application layer timeout.
> >>
> >>3. Application layer detects a network failure last (by, say,
> >>   30sec timeout) and may trigger a system-level failover.
> > 
> > 
> > Sounds like the solution is to make the switch failover detection faster.
> > If you get switch failover down to 5sec then TCP RTO shouldn't be bigger
> > than 10sec, and application will survive.
> 
> That may indeed be the best solution, we'll have to wait to hear if 
> there is any freedom there.  When this sort of thing has crossed my path 
> in other contexts, the general answer is that the device failover time 
> is fixed, and the application layer time is similarly constrained by 
> end-user expectation/requirement.  Often as not, layer 8 and 9 issues 
> tend to dominate and expect to trump (in this case layer 4 issues).

I agree that application will survive if a user makes the
application timeout twice the failover timeout.  But I'm afraid
there is no such freedom.

Basically, to minimize downtime, shorter timeouts are preferred
as long as the probability of mis-detection is kept low at a
certain level.

In practice, failover timeouts for bonding, switches, or routers
are determined by heuristics.  Users know what timeout values and
retry counts of probe packets are suitable for detecting failure
of a certain combination of network equipments. (e.g., 5sec
timeout, retries 4 times)  Shorter is better.

And application timeout (or system timeout) is given as an
end-user requirement.  There is little change of negotiation,
really.  And again shorter (than requirement, if possible) is
better.

Regards,

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
