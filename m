From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: two gateways with one NIC
Date: Mon, 9 Apr 2007 17:23:02 -0400
Message-ID: <20070409212302.GF2299@csclub.uwaterloo.ca>
References: <20070409145403.GB2299@csclub.uwaterloo.ca> <1176134180.686.102.camel@owl.home.ie> <20070409161142.GC2299@csclub.uwaterloo.ca> <461A663E.4050904@trash.net> <20070409161932.GA2302@csclub.uwaterloo.ca> <1176138144.686.115.camel@owl.home.ie> <20070409172343.GD2299@csclub.uwaterloo.ca> <1176141931.686.120.camel@owl.home.ie> <20070409181158.GB2302@csclub.uwaterloo.ca> <1176143047.686.123.camel@owl.home.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: W Agtail <wagtail@iol.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from csclub1.cs.uwaterloo.ca ([129.97.7.226]:38141 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965915AbXDIVXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 17:23:05 -0400
Content-Disposition: inline
In-Reply-To: <1176143047.686.123.camel@owl.home.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2007 at 07:24:07PM +0100, W Agtail wrote:
> Yup, I've been flushing iptables each time. This is what we have atm:
> iptables -n -v -t mangle -L
> 
> Chain PREROUTING (policy ACCEPT 12656 packets, 2518K bytes)
>  pkts bytes target     prot opt in     out     source
> destination
>     0     0 LOG        tcp  --  *      *       0.0.0.0/0
> 0.0.0.0/0           tcp spt:8088 LOG flags 0 level 4 prefix `fwmark 1: '
>     0     0 LOG        tcp  --  *      *       0.0.0.0/0
> 0.0.0.0/0           tcp spt:8089 LOG flags 0 level 4 prefix `fwmark 2: '
>     0     0 MARK       tcp  --  *      *       0.0.0.0/0
> 0.0.0.0/0           tcp spt:8088 MARK set 0x1
>     0     0 MARK       tcp  --  *      *       0.0.0.0/0
> 0.0.0.0/0           tcp spt:8089 MARK set 0x2
>     0     0 LOG        all  --  *      *       0.0.0.0/0
> 0.0.0.0/0           MARK match 0x1 LOG flags 0 level 4 prefix `marked 1:
> '
>     0     0 LOG        all  --  *      *       0.0.0.0/0
> 0.0.0.0/0           MARK match 0x2 LOG flags 0 level 4 prefix `marked 2:
> '
> 
> Chain INPUT (policy ACCEPT 10664 packets, 2438K bytes)
>  pkts bytes target     prot opt in     out     source
> destination
> 
> Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source
> destination
> 
> Chain OUTPUT (policy ACCEPT 6311 packets, 896K bytes)
>  pkts bytes target     prot opt in     out     source
> destination
> 
> Chain POSTROUTING (policy ACCEPT 6311 packets, 896K bytes)
>  pkts bytes target     prot opt in     out     source
> destination

Odd how the packet count on those mangle table entries is 0.  It seems
like it is never even getting to there.  Do you need a rule in the
output chain telling it to send some packets to the mangle table?  That
doesn't make sense either though.

--
Len Sorensen
