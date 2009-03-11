From: Marian =?utf-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Wed, 11 Mar 2009 12:03:45 +0100
Message-ID: <20090311110345.GA26294@bts.sk>
References: <20090309112521.GB37984@bts.sk> <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com> <20090309200505.GA58375@bts.sk> <20090309.170927.130334650.davem@davemloft.net> <87bps8fkaw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from saus.bts.sk ([194.160.23.4]:62468 "EHLO saus.bts.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754040AbZCKLDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 07:03:46 -0400
Content-Disposition: inline
In-Reply-To: <87bps8fkaw.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 11:03:35AM +0100, Andi Kleen wrote:
> > You say "was" as if this was a recent change.  Linux has been doing
> > receive buffer autotuning for at least 5 years if not longer.
> 
> I think his point was the only now does it become a visible problem
> as >= 1GB of memory is wide spread, which leads to 4MB rx buffer sizes.

Yes, exactly! We run into this after number of workstations were upgraded
at once to a new hardware with 2GB of RAM.

> Perhaps this points to the default buffer sizing heuristics to 
> be too aggressive for >= 1GB?
> 
> Perhaps something like this patch? Marian, does that help?

Sure - as it lowers the maximum from 4MB to 2MB, the net result is that
RTTs at 100 Mbps immediately went down from 267 msec into:

--- x.x.x.x ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 8992ms
rtt min/avg/max/mdev = 134.417/134.770/134.911/0.315 ms

Still this is too high for 100 Mpbs network, since the RTTs with 64 KB static
rx buffer look like this (with no performance penalty):

--- x.x.x.x ping statistics --
10 packets transmitted, 10 received, 0% packet loss, time 9000ms
rtt min/avg/max/mdev = 5.163/5.355/5.476/0.102 ms

I.e. the patch significantly helps as expected, however having one static
limit for all NIC speeds as well as for the whole range of RTTs is suboptimal 
by principle.


   Thanks & kind regards,

       M.

