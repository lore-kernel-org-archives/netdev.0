From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] Flow Control and Port Mirroring
Date: Mon, 8 Nov 2010 13:59:42 +0900
Message-ID: <20101108045942.GA7504@verge.net.au>
References: <20101028115403.GA16206@verge.net.au>
 <AANLkTi=QXBi4wmJS1TY0P=s+11Vjp0v=AfWOdFb4vrCj@mail.gmail.com>
 <20101030025932.GG12842@verge.net.au>
 <201011081341.23529.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51788 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab0KHFAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 00:00:02 -0500
Content-Disposition: inline
In-Reply-To: <201011081341.23529.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 08, 2010 at 01:41:23PM +1030, Rusty Russell wrote:
> On Sat, 30 Oct 2010 01:29:33 pm Simon Horman wrote:
> > [ CCed VHOST contacts ]
> > 
> > On Thu, Oct 28, 2010 at 01:22:02PM -0700, Jesse Gross wrote:
> > > On Thu, Oct 28, 2010 at 4:54 AM, Simon Horman <horms@verge.net.au> wrote:
> > > > My reasoning is that in the non-mirroring case the guest is
> > > > limited by the external interface through wich the packets
> > > > eventually flow - that is 1Gbit/s. But in the mirrored either
> > > > there is no flow control or the flow control is acting on the
> > > > rate of dummy0, which is essentailly infinate.
> > > >
> > > > Before investigating this any further I wanted to ask if
> > > > this behaviour is intentional.
> > > 
> > > It's not intentional but I can take a guess at what is happening.
> > > 
> > > When we send the packet to a mirror, the skb is cloned but only the
> > > original skb is charged to the sender.  If the original packet is
> > > delivered to localhost then it will be freed quickly and no longer
> > > accounted for, despite the fact that the "real" packet is still
> > > sitting in the transmit queue on the NIC.  The UDP stack will then
> > > send the next packet, limited only by the speed of the CPU.
> > 
> > That would explain what I have observed.
> 
> I can't find the thread (what is ovs-dev?),

Sorry, yes its on ovs-dev.
http://openvswitch.org/pipermail/dev_openvswitch.org/2010-October/003806.html

> but I think the tap device
> has this fundamental feature: you can blast as many packets as you want
> through it.
> 
> If that's a bad thing, we have to look harder...

There does seem to be flow control in the non-mirrored case.
So I suspect its occurring at the skb level but that breaks down when
a clone occurs. It would seem that fragment level flow control would
help this problem (which is basically what Xen's netback/netfront has),
but by this point I am speculating wildly.  I'll try and find out exactly
where the problem is occurring in order for us to have a more informed
discussion.
