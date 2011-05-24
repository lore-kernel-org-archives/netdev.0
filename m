From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Tue, 24 May 2011 11:03:40 -0400
Message-ID: <20110524150340.GH21309@gospo.rdu.redhat.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com> <20110523151336.GF21309@gospo.rdu.redhat.com> <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841Ab1EXPD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 11:03:57 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 10:00:23PM +0800, Am=E9rico Wang wrote:
> On Mon, May 23, 2011 at 11:13 PM, Andy Gospodarek <andy@greyhouse.net=
> wrote:
> > On Mon, May 23, 2011 at 08:45:14PM +0800, Am=E9rico Wang wrote:
> >> Hello, Jay, Andy,
> >>
> >> Is there any peculiar reason that bonding code has to stay
> >> in drivers/net/ directory?
> >>
> >> Since bonding and bridge are somewhat similar, both of
> >> which are used to "bond" two or more devices into one,
> >> and bridge code is already in net/bridge/, so I think it also
> >> makes sense to move bonding code into net/bonding/ too.
> >>
> >> This could also help to grep the source more easily. :)
> >>
> >> What do you think about the patch below?
> >> (Note, this patch is against net-next-2.6.)
> >>
> >
> > I would rather keep the code for bonding in drivers/net since it is
> > really a pure device (though not directly tied to any specific
> > hardware) rather than a device + forwarding or management code.
>=20
> Is this a reason strong enough to leave it to drivers/net/ ?
> I think it is generic enough to be moved to net/ directory... :-/
>=20

I think the distinction is an important one and is one of the main
reasons why I would like to see bonding stay in drivers/net.

> >
> > It has bothered me for a long time that the code just to manage the=
 VLAN
> > and bridge devices sits outside of drivers/net, but I've never prop=
osed
> > a patch to move the files as I suspect the maintainers of that code
> > would like to keep it all together. =A0Maybe it is time to do that.
> >
>=20
> You mean move net/8021q/ to drivers/net/8021q/ ?
>=20

No.  I'm talking about the parts in the bridging and vlan code that
specifically setup devices, not all of the code.  I would be happier
if code that created objects of type net_device_ops all lived in
drivers/net.  Then all the drivers (real, stacked, or virtual) are in
the same place.

It has not bothered me enough to consider posting patches, but you
should consider it if it bothers you.
