From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Wed, 25 May 2011 11:20:23 -0400
Message-ID: <20110525152023.GC11867@hmsreliant.think-freely.org>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
 <20110523151336.GF21309@gospo.rdu.redhat.com>
 <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
 <20110524163323.GB28521@hmsreliant.think-freely.org>
 <BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42383 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757794Ab1EYPUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 11:20:36 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 08:43:21PM +0800, Am=E9rico Wang wrote:
> On Wed, May 25, 2011 at 12:33 AM, Neil Horman <nhorman@tuxdriver.com>=
 wrote:
> > This all sounds like change for the sake of change to me. =A0I don'=
t see any
> > compelling argument for moving bonding (or bridging or vlans, etc) =
around at
> > all. =A0All of these software drivers have feet in multple subsyste=
ms, but that
> > just means that theres not going to be a compelling argument to mov=
e them any
> > place, =A0at least not without an immediate subsequent argument tha=
t it really
> > belonged back where it was. =A0Unless you can show a solid benefit =
to moving the
> > code, I don't see why any reorganization is needed.
>=20
> Well, as a people who worked on bonding code, I have no problem to kn=
ow
> bonding code is under drivers/net/, but for people who don't know thi=
s, probably
> net/ is the first place they want to search.
>=20
you've asked them?

cd git/net-next-2.6
find . -name '*bond*'

Thats going to find bonding code for you regardless of which place its =
in.  If
someone sufficiently unversed in working with a source tree goes lookin=
g for
some code by randomly poking around in directories, then they have bigg=
er
problems than not finding what they want in the first place they look. =
 If thats
the only thing this move is meant to solve, it seems like a non-problem=
 to me.

> The other similar thing is that pktgen is in net/core/ while netconso=
le is in
> drivers/net/, which seems a little strange too.
>=20
Its is, and loopback is in /drivers/net, as is tun-tap and xen-netfront=
 (none of
which touch actual hardware), as is slip and ppp, which are net drivers=
, but
only operate on non net hardware. ppoe is another example which operate=
s on
ethernet, but sits on top of a secondary physical device (and so has no=
 real
hardware itself).  These could all arguably be moved to /net, because t=
hey have
no real hardware, but are in drivers because they implement instances o=
f the net
driver interface.

> vlan vs macvlan is the third example.
>=20
yes, it is, macvlan, like you assert could be moved, but you could just=
 as
easily move vlan to /drivers because it implements an instance of the n=
et device
driver interface.

The bottom line is, sometimes things aren't black and white, they're gr=
ay. And
we put code where it makes the most sense at the time.  We move it when=
 it
makes sense to, but I don't hear any compelling argument to make that m=
ove.
Yes, we're not always consistent with where we put hardwareless drivers=
, but to
make a policy and shove everything to one place or another doesn't any =
more
sense.  If we do that we either wind up with things that we think of as=
 drivers
in the /net directory, or we wind up with stuff thats really protocol o=
riented
in the /drivers directory.  And if the major problem we solve by doing =
so is
making life easier for someone who otherwise wouldn't be able to find s=
aid code
with a quick grep or find operation, it really doesn't seem like its wo=
rthwhile
to me

> In short, there are three callers of netdev_rx_handler_register(), ma=
cvlan,
> bonding and bridge, only bridge code stays in net/ directory.
Why is calling netdev_rx_handler_register a gating factor here?

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
