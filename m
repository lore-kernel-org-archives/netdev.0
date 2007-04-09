From: W Agtail <wagtail@iol.ie>
Subject: Re: two gateways with one NIC
Date: Mon, 09 Apr 2007 19:24:07 +0100
Message-ID: <1176143047.686.123.camel@owl.home.ie>
References: <20070408182210.GJ3508@csclub.uwaterloo.ca>
	 <1176060547.686.95.camel@owl.home.ie>
	 <20070409145403.GB2299@csclub.uwaterloo.ca>
	 <1176134180.686.102.camel@owl.home.ie>
	 <20070409161142.GC2299@csclub.uwaterloo.ca> <461A663E.4050904@trash.net>
	 <20070409161932.GA2302@csclub.uwaterloo.ca>
	 <1176138144.686.115.camel@owl.home.ie>
	 <20070409172343.GD2299@csclub.uwaterloo.ca>
	 <1176141931.686.120.camel@owl.home.ie>
	 <20070409181158.GB2302@csclub.uwaterloo.ca>
Reply-To: wagtail@iol.ie
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc1-york1-0-0-cust229.leed.cable.ntl.com ([82.3.204.230]:31807
	"EHLO owl.home.ie" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751747AbXDISYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:24:16 -0400
In-Reply-To: <20070409181158.GB2302@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-04-09 at 14:11 -0400, Lennart Sorensen wrote:
> On Mon, Apr 09, 2007 at 07:05:31PM +0100, W Agtail wrote:
> > Nice one, but unfortunately still doesn't work.
> > I'm now not seeing any marked messages in /var/log/messages and traffic
> > still going via gw2 for port 8088.
> 
> What does 'iptables -v -t mangle -L' show at the moment?  Have you been
> flushing it between attemps to make sure you don't have conflicting
> rules?
> 
> --
> Len Sorensen

Yup, I've been flushing iptables each time. This is what we have atm:
iptables -n -v -t mangle -L

Chain PREROUTING (policy ACCEPT 12656 packets, 2518K bytes)
 pkts bytes target     prot opt in     out     source
destination
    0     0 LOG        tcp  --  *      *       0.0.0.0/0
0.0.0.0/0           tcp spt:8088 LOG flags 0 level 4 prefix `fwmark 1: '
    0     0 LOG        tcp  --  *      *       0.0.0.0/0
0.0.0.0/0           tcp spt:8089 LOG flags 0 level 4 prefix `fwmark 2: '
    0     0 MARK       tcp  --  *      *       0.0.0.0/0
0.0.0.0/0           tcp spt:8088 MARK set 0x1
    0     0 MARK       tcp  --  *      *       0.0.0.0/0
0.0.0.0/0           tcp spt:8089 MARK set 0x2
    0     0 LOG        all  --  *      *       0.0.0.0/0
0.0.0.0/0           MARK match 0x1 LOG flags 0 level 4 prefix `marked 1:
'
    0     0 LOG        all  --  *      *       0.0.0.0/0
0.0.0.0/0           MARK match 0x2 LOG flags 0 level 4 prefix `marked 2:
'

Chain INPUT (policy ACCEPT 10664 packets, 2438K bytes)
 pkts bytes target     prot opt in     out     source
destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source
destination

Chain OUTPUT (policy ACCEPT 6311 packets, 896K bytes)
 pkts bytes target     prot opt in     out     source
destination

Chain POSTROUTING (policy ACCEPT 6311 packets, 896K bytes)
 pkts bytes target     prot opt in     out     source
destination

