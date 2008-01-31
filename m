From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 09:55:45 -0800
Message-ID: <47A20BA1.8070206@hp.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>	<47A0C5B2.1000500@hp.com> <47A1B294.8080609@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Bruce Allen <ballen@gravity.phys.uwm.edu>,
	netdev@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:43204 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbYAaRzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:55:49 -0500
In-Reply-To: <47A1B294.8080609@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> netperf was used without any special tuning parameters. Usually we start 
> two processes on two hosts which start (almost) simultaneously, last for 
> 20-60 seconds and simply use UDP_STREAM (works well) and TCP_STREAM, i.e.
> 
> on 192.168.0.202: netperf -H 192.168.2.203 -t TCP_STREAL -l 20
> on 192.168.0.203: netperf -H 192.168.2.202 -t TCP_STREAL -l 20
> 
> 192.168.0.20[23] here is on eth0 which cannot do jumbo frames, thus we 
> use the .2. part for eth1 for a range of mtus.
> 
> The server is started on both nodes with the start-stop-daemon and no 
> special parameters I'm aware of.


So long as you are relying on external (netperf relative) means to 
report the throughput, those command lines would be fine.  I wouldn't be 
comfortably relying on the sum of the netperf-reported throughtputs with 
those comand lines though.  Netperf2 has no test synchronization, so two 
separate commands, particularly those initiated on different systems, 
are subject to skew errors.  99 times out of ten they might be epsilon, 
but I get a _little_ paranoid there.

There are three alternatives:

1) use netperf4.  not as convenient for "quick" testing at present, but 
it has explicit test synchronization, so  you "know" that the numbers 
presented are from when all connections were actively transferring data

2) use the aforementioned "burst" TCP_RR test.  This is then a single 
netperf with data flowing both ways on a single connection so no issue 
of skew, but perhaps an issue of being one connection and so one process 
on each end.

3) start both tests from the same system and follow the suggestions 
contained in :

<http://www.netperf.org/svn/netperf2/tags/netperf-2.4.4/doc/netperf.html>

particluarly:

<http://www.netperf.org/svn/netperf2/tags/netperf-2.4.4/doc/netperf.html#Using-Netperf-to-Measure-Aggregate-Performance>

and use a combination of TCP_STREAM and TCP_MAERTS (STREAM backwards) tests.

happy benchmarking,

rick jones
