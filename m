From: Willy Tarreau <w@1wt.eu>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Mon, 29 Apr 2013 00:33:55 +0200
Message-ID: <20130428223355.GA28736@1wt.eu>
References: <20130419120651.4e646976@nehalam.linuxnetplumber.net> <20130419194537.GA1633@kroah.com> <20130419.155859.1092595631804890737.davem@davemloft.net> <51727C76.6010501@redhat.com> <5172ACCB.9050203@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	Eric Leblond <eric@regit.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Luigi Rizzo <rizzo@iet.unipi.it>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:33665 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437Ab3D1WeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Apr 2013 18:34:10 -0400
Content-Disposition: inline
In-Reply-To: <5172ACCB.9050203@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

On Sat, Apr 20, 2013 at 10:57:15AM -0400, Jamal Hadi Salim wrote:
> On 13-04-20 07:31 AM, Daniel Borkmann wrote:
> 
> >Also, I just looked over Netmap's Usenix paper from 2012, where they
> >compare netmap against pktgen, and while they state the version of the 
> >FreeBSD
> >kernel
> >where they did the evaluation on, they just don't even mention the Linux'
> >kernel version, their Linux kernel setup etc. Not even mentioning a
> >comparison
> >of PF_PACKET+fanout (similarly as the PF_RING project seems to avoid this
> >comparison and only presents perf numbers where they just count packets !).
> >Also, I've seen other papers published in 2012 on this topic, where they
> >compare performance with a 2.6.2x kernel, hm, quite sad actually.
> 
> I hope I can put your doubts to rest. Netmap does provide the 
> performance it claims to. I did play with it about 6-9 months back and i 
> was able to loopback wirerate 10Gbps (~14.4Mpps) 64B packets on a 
> _single core_. i.e i send to from machine A to B which echoes back to 
> the sender via a driver hack i had on the intel driver and i count the 
> packets. I should note that this was with machines that have circa 2010 
> capabilities (and they were cheap too).

I second this. I experimented packet filtering and generation at line rate
on a single core with netmap. This is ~28 Mpps on 2 cores. I could barely
achieve 8.8 Mpps using the all 6 cores in this machine using AF_PACKET and
mmap.

There are currently shortcomings to netmap, including the loss of the csum
information from incoming packets, and lack of support for gso/tso for outgoing
ones. I don't much like the way it bypasses the driver using netif_rx() etc...
and would prefer a design which sits between the NIC and the driver so as to
be as much transparent as possible. But for some specific usages, it can be
great. And it's true that for capturing line-rate traffic on production
systems without eating all their resources, it's nice as well.

I don't know if it's mature enough for being usable as-is in the kernel,
but I think it could get enough attention to significantly improve.

Regards,
Willy
