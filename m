From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 2 Apr 2014 22:52:15 +0100
Message-ID: <20140402215215.GO11670@casper.infradead.org>
References: <5332B1FE.7080102@mojatatu.com>
 <53330639.8050403@cumulusnetworks.com>
 <20140326165934.GH2869@minipsycho.orion>
 <533312A3.5070600@cumulusnetworks.com>
 <20140326180356.GK2869@minipsycho.orion>
 <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
 <533C1F91.6000704@greyhouse.net>
 <20140402152546.GB3596@tuxdriver.com>
 <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
 <CAGVrzcZCU+fMQ0XwNa-3j3ATtSu4rDxL=+Hcwc4nTUj89A8ZZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48845 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933420AbaDBVwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 17:52:19 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcZCU+fMQ0XwNa-3j3ATtSu4rDxL=+Hcwc4nTUj89A8ZZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/14 at 09:47am, Florian Fainelli wrote:
> 2014-04-02 9:15 GMT-07:00 Scott Feldman <sfeldma@cumulusnetworks.com>=
:
> > On Apr 2, 2014, at 8:25 AM, John W. Linville <linville@tuxdriver.co=
m> wrote:
> >> On Wed, Apr 02, 2014 at 10:32:49AM -0400, Andy Gospodarek wrote:
> >>> Maybe this all seems to matter-of-fact and the discussion has
> >>> evolved well beyond something this high-level, but there still se=
ems
> >>> to be significant discussion about whether or not the ASIC should=
 be
> >>> exported as a netdev and I'm just not seeing a compelling reason.
> >>> This was my attempt to explain why.  :)
> >>
> >> Andy and I discussed this off-line, so I am admittedly partial to
> >> the conclusions we shared as reflected above... :-)
> >>
> >> While I might be convinced that there should be _something_ to
> >> represent the switch chip for some purpose (e.g. topology mapping)=
,
> >> I'm not at all convinced that thing should be a netdev.  I don't s=
ee
> >> where the switch chip by itself looks much like any other netdev a=
t
> >> all, especially once you model the actual front-panel ports with
> >> their own netdevs.  I do know that having an extra "magic netdev"
> >> in the wireless space added a lot of confusion for no clear gain,
> >> leading to it later being abolished.
> >>
> >> Modeling at the switch level might make more sense from a flow
> >> management perspective?  But if those flows are managed using a ne=
tlink
> >> protocol, does it matter what sort of entity is listening and acti=
ng
> >> on those messages?  If a switch-specific interface is needed for t=
hat,
> >> we should build it rather than pretending it looks like a netdev.
> >> I also think that throwing the DSA switches in with flow-based and
> >> "Enterprise" switches may just be confusing things.
> >>
> >> I think that the opening bid should be a minimal hardware driver t=
hat
> >> models each front-panel port with a netdev and passes all traffic
> >> to/from the CPU.  Intelligence beyond that should be added on a
> >> 'can-do' basis, with individual drivers (or corresponding userland
> >> components) listening to existing netlink traffic and implementing
> >> support for existing protocols to the best of their abilities.
> >> Missing functionality in the netlink protocols or other functions
> >> (e.g. bonding, bridging, etc) can be evolved over time as we disco=
ver
> >> missing bits required for switch acceleration.
> >
> > I agree completely with your/Andy=E2=80=99s view.  It=E2=80=99s the=
 switch port, not the switch, that needs to be modeled as a netdev.  Th=
e switch port is the abstraction that allows other existing virtual dev=
ices (bridges, bond, vxlans, etc) to cuddle against.  Is a switch port =
a special netdev in some way?  At a high level, not really.  I mean in =
sense it=E2=80=99s just eth48 on a super NIC.  OK, there may be some ad=
vantage to setting a IFF_SWITCH_PORT on the switch port netdev, so cudd=
ling netdevs could get a hint that their data plane might be offloaded.
> >
> > I=E2=80=99ve been back-and-forth on the switch netdev.  Today I=E2=80=
=99m not for it.  But I=E2=80=99m still searching for a reason.  At one=
 point I thought a switch netdev would be nice in a L3 router case wher=
e we needed a router IP address to do things like OSPF unnumbered inter=
faces, but even in that case, we can just put the router IP on lo.  Ano=
ther reason would be to use the switch netdev as a place for switch-wid=
e settings and status.  For example,
> > ethtool -S stats on switch netdev would show switch-wide stats like=
 ACL drops or something like that.  Maybe a switch device is modeled as=
 a new device class?  I guess it comes down to how much is duplicated b=
etween different vendors' switch driver implementations.
>=20
> I think the idea behind exposing a switch net_device is to account fo=
r
> all special cases where there is not already an existing and
> well-defined model for switch-wide events/control/information that we
> might want to have. Why a net_device, because the switch ports will
> already be exposed as such, so mostly for consistency with the
> presented user-space interface. Whether that net_device exposes
> different child devices of different classes, e.g: MTD partitions to
> access firmware updates, SPI master/slave controller(s), MDIO
> controller(s), is yet to be defined I suppose.

Having a master net_device seemed logical to me at first just
like it always made sense to me to have software bridges be
represented by a net_device. I agree with a lot of the concerns
though.

I see the following uses for a master net_device:
 - represent slave/master relationship and provide IFF_UP control
 - expose non port specific statistics
 - flow configuration
 - tunnel configuration
 - allow creation of virtual ports that are not backed up with HW

I want to expand on the last point a bit. I specifically did not
mention IP configuration above which is what the bridge master is
used frequently. I absolutely like the OVS model where multiple
internal ports can be created which hook into the network stack
and can thus be assigned IPs. The model allows for separate internal
ports to be configured as different VLAN access ports for example.
They also provide multiple AF_PACKET rx handlers, etc.

 sw1p1 -+
 sw1p2 -+       +-sw1int0 (ip=3D30.0.0.1) -> netif_rx()
 sw1p3 -+- sw1 -+-sw1int1 (vlan=3D10, ip=3D10.0.0.1) -> netif_rx()
 sw1p4 -+       +-sw1vxlan0 (remote_ip=3D20.0.0.2)

If supported by the chip, flows can be setup automatically to
feed these virtual ports and setup encapsultion. Others will
require software fallback. Some will not support it at all.
