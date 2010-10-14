From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Thu, 14 Oct 2010 08:09:39 +0000
Message-ID: <20101014080939.GA7710@ff.dom.local>
References: <4CB1A22B.9090701@gmail.com> <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com> <20101012101022.GA8578@ff.dom.local> <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com> <20101012215932.GA1945@del.dom.local> <4CB4DE6E.7030802@hp.com> <20101013062649.GA6915@ff.dom.local> <20101013233653.1e363692.billfink@mindspring.com> <20101014064404.GA6219@ff.dom.local> <20101014031354.e172d737.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40994 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab0JNJqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 05:46:30 -0400
Received: by bwz15 with SMTP id 15so213855bwz.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 02:46:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101014031354.e172d737.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 14, 2010 at 03:13:54AM -0400, Bill Fink wrote:
> On Thu, 14 Oct, Jarek Poplawski wrote:
> 
> > On Wed, Oct 13, 2010 at 11:36:53PM -0400, Bill Fink wrote:
> > > On Wed, 13 Oct 2010, Jarek Poplawski wrote:
> > > 
> > > > On Tue, Oct 12, 2010 at 03:17:18PM -0700, Rick Jones wrote:
> > > > >>> my burst problem is the only semi-legitimate motivation i can think
> > > > >>> of. the only other possible motivations i can imagine are setting
> > > > >>> "limit" to buffer more than 4GB of packets and setting "rate" to
> > > > >>> something more than 32 gigabit; both of these seem kind of dubious. is
> > > > >>> there something else you had in mind?
> > > > >>
> > > > >>
> > > > >> No, mainly 10 gigabit rates and additionally 64-bit stats.
> > > > >
> > > > > Any issue for bonded 10 GbE interfaces?  Now that the IEEE have ratified 
> > > > > (June) how far out are 40 GbE interfaces?  Or 100 GbE for that matter.
> > > > 
> > > > Alas packet schedulers using rate tables are still around 1G. Above 2G
> > > > they get less and less accurate, so hfsc is recommended.
> > > 
> > > I was just trying to do an 8 Gbps rate limit on a 10-GigE path,
> > > and couldn't get it to work with either htb or tbf.  Are you
> > > saying this currently isn't possible?
> > 
> > Let's start from reminding that no precise packet scheduling should be
> > expected with gso/tso etc. turned on. I don't know current hardware
> > limits for such a non-gso traffic, but for 8 Gbit rate htb or tbf
> > would definitely have wrong rate tables (overflowed values) for packet
> > sizes below 1500 bytes.
> 
> TSO/GSO was disabled and was using 9000-byte jumbo frames
> (and specified mtu 9000 to tc command).
> 
> Here was one attempt I made using tbf:
> 
> tc qdisc add dev eth2 root handle 1: prio
> tc qdisc add dev eth2 parent 1:1 handle 10: tbf rate 8900mbit buffer 1112500 limit 10000 mtu 9000
> tc filter add dev eth2 protocol ip parent 1: prio 1 u32 match ip dst 192.168.1.23 flowid 10:1
> 
> I tried many variations of the above, all without success.

The main problem are smaller packets. If you had (almost) only 9000b
frames this probably could work. But smaller packets (I don't remember
exact limits) with wrong rate table values might go almost unaccounted.

> > > Or are you saying to use
> > > this hfsc mechanism, which there doesn't seem to be a man page
> > > for?
> > 
> > There was a try:
> > http://lists.openwall.net/netdev/2009/02/26/138
> 
> Thanks for the pointer.  I will check it out later in detail,
> but I'm already having difficulty with deciding if I have the
> tc commands right for tbf and htb, and hfsc looks even more
> involved.

I don't know much about hfsc either, but it seems, with simplest
configs (second slope only) it shouldn't be much different from htb
or tbf.

Jarek P.
