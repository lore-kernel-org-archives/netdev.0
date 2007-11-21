From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCHv6 0/3] Interface group patches
Date: Wed, 21 Nov 2007 16:56:02 +0100
Message-ID: <1195660563.6691.5.camel@bzorp.balabit>
References: <11955644701165-git-send-email-panther@balabit.hu>
	 <Pine.LNX.4.64.0711201425530.32378@fbirervta.pbzchgretzou.qr>
	 <4742E68C.2000802@balabit.hu>
	 <20071120.134242.177093096.davem@davemloft.net>
	 <47437B12.9090009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, panther@balabit.hu,
	jengelh@computergmbh.de, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47437B12.9090009@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-11-21 at 01:25 +0100, Patrick McHardy wrote:
> David Miller wrote:
> > From: Laszlo Attila Toth <panther@balabit.hu>
> > Date: Tue, 20 Nov 2007 14:52:12 +0100
> >=20
> >> Jan Engelhardt =C3=ADrta:
> >>> On Nov 20 2007 14:14, Laszlo Attila Toth wrote:
> >>>> This is the 6th version of our interface group patches.
> >>>>
> >>>> The interface group value can be used to manage different interf=
aces
> >>>> at the same time such as in netfilter/iptables.
> >>> I take it you could not use...?
> >>> 	iptables -i iif1 -j dosomething
> >>> 	iptables -i iif2 -j dosomething
> >> This kind of usage requires static interface names. But there are=20
> >> dynamic interfaces such as ppp, where the actual name is not alway=
s=20
> >> known or sometimes they exist sometimes not. It is difficult to us=
e=20
> >> iptables this way, and every ifup/ifdown requires change in the ip=
tables=20
> >> ruleset (donwload it, modify and upload to the kernel). It may be =
too slow.
> >=20
> > This is actually not true these days.
> >=20
> > When network devices are created user events are generated and the
> > user can rename the device however they like using a mapping table =
of
> > any kind.
> >=20
> > And at such point the problem you present doesn't actually exist, y=
ou
> > can know what the device will be named.
> >=20
> > And if rule loading dynamically is slow, we should fix that instead=
 of
> > creating infrastructure and interfaces we don't actually need.
>=20
>=20
> I actually like this feature. Matching on names in iptables
> has always been one of the major bottlenecks, taking
> (according to my last measurement, which is some time ago)
> about 1-2% of the total performance. This is of course in
> large parts because the interface match is present on *every*
> rule, but still some way to logically group interfaces seems
> useful to me, not only for iptables, but also for routing rules,
> traffic classifiers, af_packet sockets etc.
>=20
> I'm working on the incremental ruleset changing API BTW :)
> One of the changes will be that interface matching is not
> a default part of every rule, and without wildcards it will
> use the ifindex. But since the cost of this feature seems
> pretty low, I don't see a compelling reason against it.

We are also using interface groups from userspace applications (hence
the netlink notification).=20

ppp comes up, an interface is created according to the pppd
configuration, which then assigns the interface to the given group.
another application (a proxy based firewall in our example) listens to
this notification and binds to the new interface as well.

--=20
Bazsi

-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
