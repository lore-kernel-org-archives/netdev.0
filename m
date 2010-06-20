From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Sun, 20 Jun 2010 16:41:31 +0200
Message-ID: <OFE5DDA53C.8EDE0B1A-ONC1257748.00467368-C1257748.0050B4A2@transmode.se>
References: <20100618073309.GB14513@mail.wantstofly.org> <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se> <20100618095923.GC14513@mail.wantstofly.org> <OF8E185B56.9B8AB610-ONC1257746.003A78DF-C1257746.003D4C6C@transmode.se> <20100618121223.GH14513@mail.wantstofly.org> <OF4FC7639D.8FBCAF3B-ONC1257746.004AF9D3-C1257746.005397F6@transmode.se> <20100618201243.GK14513@mail.wantstofly.org> <OF27FDE4E4.06C565FF-ONC1257747.004A175A-C1257747.004EF252@transmode.se> <20100619165642.GP14513@mail.wantstofly.org> <OF9D3E1FC3.D7320E72-ONC1257747.0066095A-C1257747.006751E1@transmode.se> <20100619185739.GQ14513@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:50942 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725Ab0FTOnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jun 2010 10:43:18 -0400
In-Reply-To: <20100619185739.GQ14513@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek <buytenh@wantstofly.org> wrote on 2010/06/19 20:57:39:
>
> On Sat, Jun 19, 2010 at 08:48:31PM +0200, Joakim Tjernlund wrote:
>
> > > > > > Not sure how one would express whether VLAN tags should be stripped
> > > > > > off or not when egressing the HW switch's physical port.
> > > > >
> > > > > If you transmit a packet onto 'lan', it will be sent to the switch chip
> > > > > with an "untagged" DSA tag.  If you transmit a packet onto 'lan.123',
> > > > > it will be sent to the switch chip with a "tagged" DSA tag.  See
> > > > > net/dsa/tag_dsa.c for details.
> > > >
> > > > Ah, now I get it, thanks.
> > > > However, how does this work for LAN to LAN pkgs? LAN1 and LAN2 could be
> > > > in the same VLAN but one is implicit(port) VLAN and the
> > > > other is explicit.
> > >
> > > If you tell the HW switch to forward these packets, they will never
> > > appear at the CPU interface, so the DSA tagging/untagging doesn't enter
> > > the picture.
> >
> > "tell the HW switch"? Doesn't DSA do that already?
>
> Not in its current iteration, as I've explained in previous emails.

Sorry, I didn't quite get that.

>
>
> > If not, what is the point of DSA then if it doesn't use the native
> > forwarding capabilities of the HW switch?
>
> The point is and always was to provide a framework for proper integration
> of hardware switch chips into the Linux kernel.  This framework doesn't
> become useless just because it doesn't already support every single
> hardware feature at this point.

Right, sorry if I sounded a bit harsh.

So DSA currently does a very minimal config of the HW switch to get
things going.
If you want to do something more fancy one has to
add a control plane to DSA which would possibly talk
to a user space app. Is that correct?

>
>
> > > > How do I config the HW switch to do that?
> > >
> > > Tell the switch that the vlan is native on one of the ports but not on
> > > the other.  It's been a while since I looked at the chip docs but there
> > > are ways of doing this.
> >
> > The current DSA impl. does not support this? There should be some
> > way to manage this within the DSA framework.
>
> Have you even tried the DSA code?

Not yet and I don't have any MV HW either :(

