From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Thu, 26 May 2011 09:50:54 -0400
Message-ID: <20110526135053.GB12617@hmsreliant.think-freely.org>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
 <20110523151336.GF21309@gospo.rdu.redhat.com>
 <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
 <20110524163323.GB28521@hmsreliant.think-freely.org>
 <BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
 <20110525152023.GC11867@hmsreliant.think-freely.org>
 <BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53438 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756616Ab1EZNvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 09:51:01 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2011 at 05:32:08PM +0800, Am=E9rico Wang wrote:
> On Wed, May 25, 2011 at 11:20 PM, Neil Horman <nhorman@tuxdriver.com>=
 wrote:
> > On Wed, May 25, 2011 at 08:43:21PM +0800, Am=E9rico Wang wrote:
> >> On Wed, May 25, 2011 at 12:33 AM, Neil Horman <nhorman@tuxdriver.c=
om> wrote:
> >> > This all sounds like change for the sake of change to me. =A0I d=
on't see any
> >> > compelling argument for moving bonding (or bridging or vlans, et=
c) around at
> >> > all. =A0All of these software drivers have feet in multple subsy=
stems, but that
> >> > just means that theres not going to be a compelling argument to =
move them any
> >> > place, =A0at least not without an immediate subsequent argument =
that it really
> >> > belonged back where it was. =A0Unless you can show a solid benef=
it to moving the
> >> > code, I don't see why any reorganization is needed.
> >>
> >> Well, as a people who worked on bonding code, I have no problem to=
 know
> >> bonding code is under drivers/net/, but for people who don't know =
this, probably
> >> net/ is the first place they want to search.
> >>
> > you've asked them?
> >
> > cd git/net-next-2.6
> > find . -name '*bond*'
>=20
> No, somone asked me why bonding is not in net/ and after some thinkin=
g,
> I see no reasons myself (thus sent this patch).
>=20
"Why not" rarely seems like a good reason to change things to me :)

>=20
> >> The other similar thing is that pktgen is in net/core/ while netco=
nsole is in
> >> drivers/net/, which seems a little strange too.
> >>
> > Its is, and loopback is in /drivers/net, as is tun-tap and xen-netf=
ront (none of
> > which touch actual hardware), as is slip and ppp, which are net dri=
vers, but
> > only operate on non net hardware. ppoe is another example which ope=
rates on
> > ethernet, but sits on top of a secondary physical device (and so ha=
s no real
> > hardware itself). =A0These could all arguably be moved to /net, bec=
ause they have
> > no real hardware, but are in drivers because they implement instanc=
es of the net
> > driver interface.
> >
> >> vlan vs macvlan is the third example.
> >>
> > yes, it is, macvlan, like you assert could be moved, but you could =
just as
> > easily move vlan to /drivers because it implements an instance of t=
he net device
> > driver interface.
>=20
> Then I agree here.
>=20
> >
> > The bottom line is, sometimes things aren't black and white, they'r=
e gray. And
> > we put code where it makes the most sense at the time. =A0We move i=
t when it
> > makes sense to, but I don't hear any compelling argument to make th=
at move.
> > Yes, we're not always consistent with where we put hardwareless dri=
vers, but to
> > make a policy and shove everything to one place or another doesn't =
any more
> > sense. =A0If we do that we either wind up with things that we think=
 of as drivers
> > in the /net directory, or we wind up with stuff thats really protoc=
ol oriented
> > in the /drivers directory. =A0And if the major problem we solve by =
doing so is
> > making life easier for someone who otherwise wouldn't be able to fi=
nd said code
> > with a quick grep or find operation, it really doesn't seem like it=
s worthwhile
> > to me
> >
>=20
> Well, the problem is our code organisation, if we could organize the =
code
> in a better way that would help grepping the code.
>=20
You've already demonstrated that its pretty easy.  Do we really need to=
 cater to
someone who can't figure out to look for something in two possible plac=
es when
it will just cause confusion for those of us do.  And again, beyond tha=
t
tradeoff, I still don't see any advantage to doing this.

> >> In short, there are three callers of netdev_rx_handler_register(),=
 macvlan,
> >> bonding and bridge, only bridge code stays in net/ directory.
> > Why is calling netdev_rx_handler_register a gating factor here?
> >
>=20
> I don't think other drivers are supposed to use this function to regi=
ster
> a packet handler, which is an important difference from my view.
>=20
Note you just referred to the bridge/bond and vlan code as 'drivers' :)=
=2E  And
why is that function the gating factor?  Why not register_netdev?  or
netif_receive_skb or dev_add_pack?  They all relate to the creation of =
device
interface and the reception of network data.

The fact is, bonding/bridging/vlans/tunnels/etc all have aspects that
make them more than just drivers.  They are where they are for a myrria=
d of
reasons.  Moving them around changes their location, but does _nothing_=
 about
the underlying fact that they're driver code plus other stuff, and as s=
uch
provides no real advantage in terms of organization.

Neil
