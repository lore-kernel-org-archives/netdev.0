From: Rick Jones <rick.jones2@hp.com>
Subject: Re: SO_REUSEPORT?
Date: Thu, 07 Aug 2008 13:14:02 -0700
Message-ID: <489B578A.9030505@hp.com>
References: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>	<200808072009.34891.rdenis@simphalempin.com>	<65634d660808071058k7eb33330tcf3c7a877b7a64d@mail.gmail.com>	<489B3C53.1000202@hp.com> <20080807120359.2d62880a@extreme> <65634d660808071243yd7de635i7e780f526161b445@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:20671 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbYHGUOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 16:14:06 -0400
In-Reply-To: <65634d660808071243yd7de635i7e780f526161b445@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm not sure that's applicable for us since the server application and
> networking will max out all the CPUs on host anyway; one way or
> another we need to dispatch the work of incoming connections to
> threads on different CPUs.  If we do this in user space and do all
> accepts in one thread, the CPU of that  thread becomes the bottleneck
> (we're accepting about 40,000 connections per second).  If we have
> multiple accept threads running on different CPUs, this helps some,
> but the load is spread unevenly across the CPUs and we still can't get
> the highest connection rate.  So it seems we're looking for a method
> that distributes the incoming connection load across CPUs pretty
> evenly.

Well, if you _really_ want the load spread, you may need to use a 
multiqueue (at least inbound if not also later outbound) interface, 
"know" how the NIC will hash and then have N distinct port numbers each 
assigned to a LISTEN endpoint.  The old song and dance about making an N 
CPU system look as much like N single-CPU systems and all that...

Unless there are NICs you can "tell" where to send the interrupts, which 
IMO is preferable - I have a preference for the application/scheduler 
telling "networking" where to work rather than networking (or the NIC) 
telling the scheduler where to run a thread - the archives of either 
here or netnews will probalby pull-up stuff were I've talked about 
Inbound Packet Scheduling (IPS) vs Thread Optimized Packet Scheduling 
(TOPS) and limitations of simplistic address hashing to pick a 
queue/processor/whatnot :)

rick jones
