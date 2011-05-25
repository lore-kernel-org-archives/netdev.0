From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Wed, 25 May 2011 11:01:44 -0400
Message-ID: <20110525150144.GB11867@hmsreliant.think-freely.org>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
 <20110523151336.GF21309@gospo.rdu.redhat.com>
 <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
 <20110524150340.GH21309@gospo.rdu.redhat.com>
 <BANLkTi=UCH8+ZVFwZ96YvFuDqDLwq8ihkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51001 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932411Ab1EYPCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 11:02:02 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=UCH8+ZVFwZ96YvFuDqDLwq8ihkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 08:32:43PM +0800, Am=E9rico Wang wrote:
> On Tue, May 24, 2011 at 11:03 PM, Andy Gospodarek <andy@greyhouse.net=
> wrote:
> > On Tue, May 24, 2011 at 10:00:23PM +0800, Am=E9rico Wang wrote:
> >> On Mon, May 23, 2011 at 11:13 PM, Andy Gospodarek <andy@greyhouse.=
net> wrote:
> >> > On Mon, May 23, 2011 at 08:45:14PM +0800, Am=E9rico Wang wrote:
> >> >> Hello, Jay, Andy,
> >> >>
> >> >> Is there any peculiar reason that bonding code has to stay
> >> >> in drivers/net/ directory?
> >> >>
> >> >> Since bonding and bridge are somewhat similar, both of
> >> >> which are used to "bond" two or more devices into one,
> >> >> and bridge code is already in net/bridge/, so I think it also
> >> >> makes sense to move bonding code into net/bonding/ too.
> >> >>
> >> >> This could also help to grep the source more easily. :)
> >> >>
> >> >> What do you think about the patch below?
> >> >> (Note, this patch is against net-next-2.6.)
> >> >>
> >> >
> >> > I would rather keep the code for bonding in drivers/net since it=
 is
> >> > really a pure device (though not directly tied to any specific
> >> > hardware) rather than a device + forwarding or management code.
> >>
> >> Is this a reason strong enough to leave it to drivers/net/ ?
> >> I think it is generic enough to be moved to net/ directory... :-/
> >>
> >
> > I think the distinction is an important one and is one of the main
> > reasons why I would like to see bonding stay in drivers/net.
> >
>=20
> Is this a rule that we judge if a piece of code should be in net/
> or drivers/net/ ? For me, that big difference between these
> two directory is clearly if the code is generic or hardware/platform
> independent.
>=20
While thats a fine rule to draw a distinction on, it also creates other
organizational oddities.  By this reasoning, the loopback/tun-tap and x=
en
netfront drivers should also be moved to /net.  While this might be an =
ok move
to make, I think we can all agree, that while they don't touch specific
hardware, they implement instances of the driver model, and as such are
reasonably placed in /drivers.

> >> >
> >> > It has bothered me for a long time that the code just to manage =
the VLAN
> >> > and bridge devices sits outside of drivers/net, but I've never p=
roposed
> >> > a patch to move the files as I suspect the maintainers of that c=
ode
> >> > would like to keep it all together. =A0Maybe it is time to do th=
at.
> >> >
> >>
> >> You mean move net/8021q/ to drivers/net/8021q/ ?
> >>
> >
> > No. =A0I'm talking about the parts in the bridging and vlan code th=
at
> > specifically setup devices, not all of the code. =A0I would be happ=
ier
> > if code that created objects of type net_device_ops all lived in
> > drivers/net. =A0Then all the drivers (real, stacked, or virtual) ar=
e in
> > the same place.
>=20
> This would make grepping the source code more harder
> than it is, at least now we can grepping all bridge source code
> in net/bridge/, for example.
>=20
This is really a false assertion.  Theres nothing more or less hard abo=
ut
finding bonding code in /drivers than there is in /net.  grep and find =
let you
locate the code in either place equally well, and cscope really makes i=
t all
moot anyway.

Neil

> Actually the vlan case you mentioned can be another example
> to show that to moving bonding code into net/ makes sense.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
