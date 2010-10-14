From: Bill Fink <billfink@mindspring.com>
Subject: Re: tbf/htb qdisc limitations
Date: Thu, 14 Oct 2010 03:13:54 -0400
Message-ID: <20101014031354.e172d737.billfink@mindspring.com>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>
	<4CB1A22B.9090701@gmail.com>
	<AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
	<20101012101022.GA8578@ff.dom.local>
	<AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
	<20101012215932.GA1945@del.dom.local>
	<4CB4DE6E.7030802@hp.com>
	<20101013062649.GA6915@ff.dom.local>
	<20101013233653.1e363692.billfink@mindspring.com>
	<20101014064404.GA6219@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:41386 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754744Ab0JNHN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 03:13:56 -0400
In-Reply-To: <20101014064404.GA6219@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Oct, Jarek Poplawski wrote:

> On Wed, Oct 13, 2010 at 11:36:53PM -0400, Bill Fink wrote:
> > On Wed, 13 Oct 2010, Jarek Poplawski wrote:
> > 
> > > On Tue, Oct 12, 2010 at 03:17:18PM -0700, Rick Jones wrote:
> > > >>> my burst problem is the only semi-legitimate motivation i can think
> > > >>> of. the only other possible motivations i can imagine are setting
> > > >>> "limit" to buffer more than 4GB of packets and setting "rate" to
> > > >>> something more than 32 gigabit; both of these seem kind of dubious. is
> > > >>> there something else you had in mind?
> > > >>
> > > >>
> > > >> No, mainly 10 gigabit rates and additionally 64-bit stats.
> > > >
> > > > Any issue for bonded 10 GbE interfaces?  Now that the IEEE have ratified 
> > > > (June) how far out are 40 GbE interfaces?  Or 100 GbE for that matter.
> > > 
> > > Alas packet schedulers using rate tables are still around 1G. Above 2G
> > > they get less and less accurate, so hfsc is recommended.
> > 
> > I was just trying to do an 8 Gbps rate limit on a 10-GigE path,
> > and couldn't get it to work with either htb or tbf.  Are you
> > saying this currently isn't possible?
> 
> Let's start from reminding that no precise packet scheduling should be
> expected with gso/tso etc. turned on. I don't know current hardware
> limits for such a non-gso traffic, but for 8 Gbit rate htb or tbf
> would definitely have wrong rate tables (overflowed values) for packet
> sizes below 1500 bytes.

TSO/GSO was disabled and was using 9000-byte jumbo frames
(and specified mtu 9000 to tc command).

Here was one attempt I made using tbf:

tc qdisc add dev eth2 root handle 1: prio
tc qdisc add dev eth2 parent 1:1 handle 10: tbf rate 8900mbit buffer 1112500 limit 10000 mtu 9000
tc filter add dev eth2 protocol ip parent 1: prio 1 u32 match ip dst 192.168.1.23 flowid 10:1

I tried many variations of the above, all without success.

> > Or are you saying to use
> > this hfsc mechanism, which there doesn't seem to be a man page
> > for?
> 
> There was a try:
> http://lists.openwall.net/netdev/2009/02/26/138

Thanks for the pointer.  I will check it out later in detail,
but I'm already having difficulty with deciding if I have the
tc commands right for tbf and htb, and hfsc looks even more
involved.

					-Bill
