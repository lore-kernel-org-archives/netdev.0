From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: tc filter show not displaying anything
Date: Fri, 16 Dec 2011 00:33:08 -0500
Message-ID: <1324013588.8451.320.camel@denise.theartistscloset.com>
References: <1324010915.8451.319.camel@denise.theartistscloset.com>
	 <4EEAD059.5010907@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:64708 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821Ab1LPFdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 00:33:12 -0500
In-Reply-To: <4EEAD059.5010907@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-12-15 at 21:00 -0800, John Fastabend wrote:
> On 12/15/2011 8:48 PM, John A. Sullivan III wrote:
> > Hello, all.  I'm starting to feel really stupid and showing my newbidity
> > to tc.  I do a:
> > tc filter show dev eth1
> > and nothing is displayed but I suspect the filter is there because if I
> > try to add it again, the kernel complains with:
> > RTNETLINK answers: File exists
> > We have an error talking to the kernel
> > 
> > Here is what I have put together so far (disregard the silly ports - it
> > is just for netcat testing):
> > 
> > tc qdisc add dev eth1 root handle 1: hfsc default 20
> > tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit ul rate 1490kbit
> > tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 800kbit ls rate 200kbit
> > tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 10
> > tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16000kbit dmax 13ms rate 400kbit ls rate 1000kbit
> > tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 10
> > iptables -t mangle -A POSTROUTING  -p 6 --syn --dport 443 -j CONNMARK --set-mark 0x10
> > iptables -t mangle -A POSTROUTING  -p 6 -j CONNMARK --restore-mark
> > 
> > I then did:
> > 
> > root@testswitch01:~# tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x10 fw flowid 1:10
> > root@testswitch01:~# tc filter show dev eth1
> > root@testswitch01:~# tc filter show parent 1:1
> > 
> > What simple, practical thing did I mangle? Thanks - John
> > 
> 
> #tc filter show dev eth1 parent 1:1
> 
> works here.
Argh!! Thanks - worked just fine - John
