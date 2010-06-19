From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Sat, 19 Jun 2010 20:57:39 +0200
Message-ID: <20100619185739.GQ14513@mail.wantstofly.org>
References: <20100618073309.GB14513@mail.wantstofly.org> <OF68B8EEAD.B003EFE7-ONC1257746.003109DB-C1257746.0032D371@transmode.se> <20100618095923.GC14513@mail.wantstofly.org> <OF8E185B56.9B8AB610-ONC1257746.003A78DF-C1257746.003D4C6C@transmode.se> <20100618121223.GH14513@mail.wantstofly.org> <OF4FC7639D.8FBCAF3B-ONC1257746.004AF9D3-C1257746.005397F6@transmode.se> <20100618201243.GK14513@mail.wantstofly.org> <OF27FDE4E4.06C565FF-ONC1257747.004A175A-C1257747.004EF252@transmode.se> <20100619165642.GP14513@mail.wantstofly.org> <OF9D3E1FC3.D7320E72-ONC1257747.0066095A-C1257747.006751E1@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:49310 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756623Ab0FSS5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jun 2010 14:57:43 -0400
Content-Disposition: inline
In-Reply-To: <OF9D3E1FC3.D7320E72-ONC1257747.0066095A-C1257747.006751E1@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 19, 2010 at 08:48:31PM +0200, Joakim Tjernlund wrote:

> > > > > Not sure how one would express whether VLAN tags should be stripped
> > > > > off or not when egressing the HW switch's physical port.
> > > >
> > > > If you transmit a packet onto 'lan', it will be sent to the switch chip
> > > > with an "untagged" DSA tag.  If you transmit a packet onto 'lan.123',
> > > > it will be sent to the switch chip with a "tagged" DSA tag.  See
> > > > net/dsa/tag_dsa.c for details.
> > >
> > > Ah, now I get it, thanks.
> > > However, how does this work for LAN to LAN pkgs? LAN1 and LAN2 could be
> > > in the same VLAN but one is implicit(port) VLAN and the
> > > other is explicit.
> >
> > If you tell the HW switch to forward these packets, they will never
> > appear at the CPU interface, so the DSA tagging/untagging doesn't enter
> > the picture.
> 
> "tell the HW switch"? Doesn't DSA do that already?

Not in its current iteration, as I've explained in previous emails.


> If not, what is the point of DSA then if it doesn't use the native
> forwarding capabilities of the HW switch?

The point is and always was to provide a framework for proper integration
of hardware switch chips into the Linux kernel.  This framework doesn't
become useless just because it doesn't already support every single
hardware feature at this point.


> > > How do I config the HW switch to do that?
> >
> > Tell the switch that the vlan is native on one of the ports but not on
> > the other.  It's been a while since I looked at the chip docs but there
> > are ways of doing this.
> 
> The current DSA impl. does not support this? There should be some
> way to manage this within the DSA framework.

Have you even tried the DSA code?
