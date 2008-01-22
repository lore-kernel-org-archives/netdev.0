From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression
	in	2.6.24-rc6,	comparing with 2.6.22
Date: Tue, 22 Jan 2008 14:07:19 +0800
Message-ID: <1200982039.3151.120.camel@ymzhang>
References: <1199871330.3298.132.camel@ymzhang>
	 <1200043854.3265.24.camel@ymzhang>  <4787ADDA.7090602@hp.com>
	 <1200280292.3151.24.camel@ymzhang>  <478B9FE0.3040801@hp.com>
	 <1200979482.3151.103.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38518 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836AbYAVGJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 01:09:32 -0500
In-Reply-To: <1200979482.3151.103.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-01-22 at 13:24 +0800, Zhang, Yanmin wrote:
> On Mon, 2008-01-14 at 09:46 -0800, Rick Jones wrote:
> > >>*) netperf/netserver support CPU affinity within themselves with the 
> > >>global -T option to netperf.  Is the result with taskset much different? 
> > >>   The equivalent to the above would be to run netperf with:
> > >>
> > >>./netperf -T 0,7 ..
> > > 
> > > I checked the source codes and didn't find this option.
> > > I use netperf V2.3 (I found the number in the makefile).
> > 
> > Indeed, that version pre-dates the -T option.  If you weren't already 
> > chasing a regression I'd suggest an upgrade to 2.4.mumble.  Once you are 
> > at a point where changing another variable won't muddle things you may 
> > want to consider upgrading.
> > 
> > happy benchmarking,
> Rick,
> 
> I found my UDP_RR testing is just loop in netperf instead of ping-pang between
> netserver and netperf. Is it correct? TCP_RR is ok.
> 
> #./netserver
> #./netperf -t UDP_RR -l 60 -H 127.0.0.1 -i 30,3 -I 99,5 -- -P 12384 -r 1,1
I digged into netperf and netserver.

netperf binds ip 0 and port 12384 to its own socket. netserver binds ip
127.0.0.1 and port 12384 to its own socket. Then, netperf calls connect to setup server
127.0.0.1 and port 12384. Then, netperf starts sends UDP packets, but all packets netperf
sends are just received by netperf itself. netserver doesn't receive any packet.

I think netperf binding should fail, or netperf shouldn't get the packet it sends out, because
netserver already binds port 12384.

I am wondering if UDP stack in kernel has a bug.

TCP_RR testing hasn't such issue.

-yanmin


