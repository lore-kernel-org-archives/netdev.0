From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Tue, 11 Mar 2008 16:52:54 +0000
Message-ID: <20080311165253.GG26963@solarflare.com>
References: <20080305205116.5989A412541@localhost> <20080305.132112.01598419.davem@davemloft.net> <47D19147.9070609@qualcomm.com> <36D9DB17C6DE9E40B059440DB8D95F52049D5CE5@orsmsx418.amr.corp.intel.com> <65634d660803110920g5103dc60ya055a10f999b4e25@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Max Krasnyanskiy <maxk@qualcomm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@elte.hu>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:41641 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbYCKQxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 12:53:09 -0400
Content-Disposition: inline
In-Reply-To: <65634d660803110920g5103dc60ya055a10f999b4e25@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> >  Could we use something like this to reschedule NAPI onto other
> >  processors?  If we get unlucky enough to have multiple napi routines
> >  polling on a single CPU, and one or more completely idle CPUs (idle at
> >  least for softirq) then we could really use one or the other of these
> >  solutions.
> 
> Jesse,
> 
> This patch does provide a general mechanism to schedule (or
> reschedule) NAPI to other CPUs.  We implemented two scheduling
> algorithms: 1) round robin scheduling of NAPI poll function across a
> set of CPUs on a per device basis 2) scheduling stack processing by
> directing packets to a CPU (using backlog queue); a hash is done on
> the 4-tuple to direct the packets for a connection to same CPU thus
> emulating HW RSS (we will add support for those devices that can
> provide the computed hash per packet).

Recent versions of Windows that are aware of RSS will instruct network
drivers to update their RSS indirection tables so that received
packets are handled on the same CPU as the thread likely to use the
received data.  This requires that the network stack knows the hash
function, so Microsoft specified a "Toeplitz hash" for IPv4 and IPv6.
You can expect that most hardware RSS implementations will use this
function and not a simple XOR.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
