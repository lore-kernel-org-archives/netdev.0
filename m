From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 11:09:28 +1100
Message-ID: <20081008000928.GJ12021@verge.net.au>
References: <20081007011551.GA28408@verge.net.au> <20081007045145.GA23883@verge.net.au> <20081007074435.GA2700@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45121 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbYJHAJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 20:09:31 -0400
Content-Disposition: inline
In-Reply-To: <20081007074435.GA2700@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 07:44:35AM +0000, Jarek Poplawski wrote:
> On Tue, Oct 07, 2008 at 03:51:47PM +1100, Simon Horman wrote:
> > On Tue, Oct 07, 2008 at 12:15:52PM +1100, Simon Horman wrote:
> > > Hi Dave, Hi Jarek,
> 
> Hi Simon,
> 
> > > I know that you guys were/are playing around a lot in here, but
> > > unfortunately I think that "pkt_sched: Always use q->requeue in
> > > dev_requeue_skb()" (f0876520b0b721bedafd9cec3b1b0624ae566eee) has
> > > introduced a performance regression for HTB.
> ...
> > > The test machine with the tc rules and udp-sending processes
> > > has two Intel Xeon Quad-cores running at 1.86GHz. The kernel
> > > is SMP x86_64.
> > 
> > With the following patch (basically a reversal of ""pkt_sched: Always use
> > q->requeue in dev_requeue_skb()" forward ported to the current
> > net-next-2.6 tree (tcp: Respect SO_RCVLOWAT in tcp_poll()), I get some
> > rather nice numbers (IMHO).
> > 
> > 10194: 666780666bits/s 666Mbits/s
> > 10197: 141154197bits/s 141Mbits/s
> > 10196: 141023090bits/s 141Mbits/s
> > -----------------------------------
> > total: 948957954bits/s 948Mbits/s
> > 
> > I'm not sure what evil things this patch does to other aspects
> > of the qdisc code.
> 
> I'd like to establish this too. This patch was meant to remove some
> other problems possibly the simplest way. Maybe it's too simple.
> Anyway, it's kind of RFC, so the rest of the requeuing code is left
> unchanged, just for easy revoking like below. But first we should
> try to understand this more.

Agreed.

> So, thanks for testing and reporting this. (BTW, what network card
> do you use and is there multiqueuing on?)

The network card is an e1000. Acutally there are two, but I
am only using the first one. I am not sure what the Broadcom
controllers are (I can get someone to go and inspect the
machine if its important).

# lspci | grep Ether
03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
05:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)

And from dmsg

e1000e 0000:0b:00.0: setting latency timer to 64
0000:0b:00.0: 0000:0b:00.0: Failed to initialize MSI interrupts.  Falling back to legacy interrupts.
0000:0b:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:1b:78:57:dc:f2
0000:0b:00.0: eth0: Intel(R) PRO/1000 Network Connection
0000:0b:00.0: eth0: MAC: 0, PHY: 4, PBA No: d51930-003
e1000e 0000:0b:00.1: setting latency timer to 64
0000:0b:00.1: 0000:0b:00.1: Failed to initialize MSI interrupts.  Falling back to legacy interrupts.
0000:0b:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:1b:78:57:dc:f3
0000:0b:00.1: eth1: Intel(R) PRO/1000 Network Connection
0000:0b:00.1: eth1: MAC: 0, PHY: 4, PBA No: d51930-003

It is eth0 that I am using.

My kernel is compiled with CONFIG_NET_SCH_MULTIQ disabled.



-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

