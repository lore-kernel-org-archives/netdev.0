From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] e1000 performance patch
Date: Thu, 27 Apr 2006 09:07:36 -0700
Message-ID: <4450EC48.5060304@hp.com>
References: <20060426221353.GA22143@lemming.cita.utoronto.ca>	<444FF389.2090002@hp.com> <20060427024326.GA6318@lemming.cita.utoronto.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:41645 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1030193AbWD0QHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 12:07:37 -0400
To: Robin Humble <rjh@cita.utoronto.ca>
In-Reply-To: <20060427024326.GA6318@lemming.cita.utoronto.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> but clearly I should be using netperf to get more accurate cpu numbers
> and a more convincing aggregate table :-)

Well, I'll not stop you  :)

> 
> 
>>It is a bit rough/messy as a writeup, but here is what I've seen wrt the 
>>latency vs throughput tradeoffs:
>>ftp://ftp.cup.hp.com/dist/networking/briefs/nic_latency_vs_tput.txt
> 
> 
> from a quick read it looks like just the case with 32kB messages,
> multiple simultaneous clients, and driver set to unlimited ITR sees
> reduced throughput. is that right?
> 
> if so, then I'm not surprised.

There should be three basic measures there - one is the single-instance 
request-response test. The idea is to see minimum latency.  That test 
likes to see the interrupt throttle rate made very high, or disabled 
completely.

The aggregate TCP_RR's and the TCP_STREAM tests are there to show what 
effect that has on the ability to do aggregate request/response and a 
bulk transfer.

> but overall I'm actually more worried about a mix of small and large
> messages than multiple clients.


> 
> a large/small mix might well occur in 'the real world' and it'll be 2s
> until the watchdog routine can adapt the ITR. potentially that 2s will
> be at 200k ITR which is too high for large messages, and up to 2s of
> cpu will be burnt needlessly.
> 
> can netperf (or some other tool) mix up big and small message sizes
> like 'the real world' perhaps does?
> that might help me find a good frequency at which to try to adapt the
> ITR... (eg. 1, 10, 100 or 1000 times a second)

There is the "vst" (variable size test IIRC) in netperf4:

http://www.netperf.org/svn/netperf4/branches/glib_migration

The docs for netperf4 are presently pathetic.  Feel free to email me for 
bootstrapping information.  Basically, you'll need pkg-config, libxml2 
and glib-2.0 on the system.

> 
> cheers,
> robin

