From: Bill Fink <billfink@mindspring.com>
Subject: Re: tbf/htb qdisc limitations
Date: Fri, 15 Oct 2010 02:37:49 -0400
Message-ID: <20101015023749.f085006b.billfink@mindspring.com>
References: <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
	<20101012101022.GA8578@ff.dom.local>
	<AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
	<20101012215932.GA1945@del.dom.local>
	<4CB4DE6E.7030802@hp.com>
	<20101013062649.GA6915@ff.dom.local>
	<20101013233653.1e363692.billfink@mindspring.com>
	<20101014064404.GA6219@ff.dom.local>
	<20101014031354.e172d737.billfink@mindspring.com>
	<20101014080939.GA7710@ff.dom.local>
	<20101014085005.GA8349@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:51449 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756086Ab0JOGjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 02:39:41 -0400
In-Reply-To: <20101014085005.GA8349@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Oct 2010, Jarek Poplawski wrote:

> On Thu, Oct 14, 2010 at 08:09:39AM +0000, Jarek Poplawski wrote:
> > On Thu, Oct 14, 2010 at 03:13:54AM -0400, Bill Fink wrote:
> > > TSO/GSO was disabled and was using 9000-byte jumbo frames
> > > (and specified mtu 9000 to tc command).
> > > 
> > > Here was one attempt I made using tbf:
> > > 
> > > tc qdisc add dev eth2 root handle 1: prio
> > > tc qdisc add dev eth2 parent 1:1 handle 10: tbf rate 8900mbit buffer 1112500 limit 10000 mtu 9000
> > > tc filter add dev eth2 protocol ip parent 1: prio 1 u32 match ip dst 192.168.1.23 flowid 10:1
> > > 
> > > I tried many variations of the above, all without success.
> > 
> > The main problem are smaller packets. If you had (almost) only 9000b
> > frames this probably could work. [...]
> 
> On the other hand, e.g. the limit above seems too low wrt mtu & rate.

Actually, I discovered my commands above work just fine on
a 2.6.35 box:

i7test7% nuttcp -T10 -i1 192.168.1.17
 1045.3125 MB /   1.00 sec = 8768.3573 Mbps     0 retrans
 1045.6875 MB /   1.00 sec = 8772.0292 Mbps     0 retrans
 1049.5625 MB /   1.00 sec = 8804.2627 Mbps     0 retrans
 1043.1875 MB /   1.00 sec = 8750.9960 Mbps     0 retrans
 1048.6875 MB /   1.00 sec = 8796.3246 Mbps     0 retrans
 1033.4375 MB /   1.00 sec = 8669.3188 Mbps     0 retrans
 1040.7500 MB /   1.00 sec = 8730.7057 Mbps     0 retrans
 1047.0000 MB /   1.00 sec = 8783.2063 Mbps     0 retrans
 1040.0000 MB /   1.00 sec = 8724.0564 Mbps     0 retrans
 1037.4375 MB /   1.00 sec = 8702.5434 Mbps     0 retrans

10431.5608 MB /  10.00 sec = 8749.7542 Mbps 25 %TX 35 %RX 0 retrans 0.11 msRTT

The problems I encountered were on a field system running
2.6.30.10.  I will investigate upgrading the field system
to 2.6.35.

					-Bill
