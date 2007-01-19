From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [PATCH 0/12] L2 network namespace (v3)
Date: Fri, 19 Jan 2007 12:35:11 +0300
Message-ID: <200701191235.11646.dim@openvz.org>
References: <200701171851.14734.dim@openvz.org> <20070119.090745.39279848.yoshfuji@linux-ipv6.org> <m1ps9b5vdp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=euc-jp
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, containers@lists.osdl.org, alexey@sw.ru,
	saw@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:17706 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965056AbXASKNH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 05:13:07 -0500
To: YOSHIFUJI Hideaki / =?euc-jp?q?=B5=C8=C6=A3=B1=D1=CC=C0?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <m1ps9b5vdp.fsf@ebiederm.dsl.xmission.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 January 2007 10:27, Eric W. Biederman wrote:
> YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org=
> writes:
>=20
> > In article <200701171851.14734.dim@openvz.org> (at Wed, 17 Jan 2007=
 18:51:14
> > +0300), Dmitry Mishin <dim@openvz.org> says:
> >
> >> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >> L2 network namespaces
> >>=20
> >> The most straightforward concept of network virtualization is comp=
lete
> >> separation of namespaces, covering device list, routing tables, ne=
tfilter
> >> tables, socket hashes, and everything else.
> >>=20
> >> On input path, each packet is tagged with namespace right from the
> >> place where it appears from a device, and is processed by each lay=
er
> >> in the context of this namespace.
> >> Non-root namespaces communicate with the outside world in two ways=
: by
> >> owning hardware devices, or receiving packets forwarded them by th=
eir parent
> >> namespace via pass-through device.
> >
> > Can you handle multicast / broadcast and IPv6, which are very impor=
tant?
>=20
> The basic idea here is very simple.
>=20
> Each network namespace appears to user space as a separate network st=
ack,
> with it's own set of routing tables etc.
>=20
> All sockets and all network devices (the sources of packets) belong
> to exactly one network namespace. =20
>=20
> >From the socket or the network device a packet enters the network st=
ack
> you can infer the network namespace that it will be processed in.
> Each network namespace should get it own complement of the data struc=
tures
> necessary to process packets, and everything should work.
>=20
> Talking between namespaces is accomplished either through an external=
 network,
> or through a special pseudo network device.  The simplest to implemen=
t
> is two network devices where all packets transmitted on one are recei=
ved
> on the other.  Then by placing one network device in one namespace an=
d
> the other in another interface it looks like two machines connected b=
y
> a cross over cable.
>=20
> Once you have that in a one namespace you can connect other namespace=
s
> with the existing ethernet bridging or by configuring one of the
> namespaces as a router and routing traffic between them.
>=20
>=20
> Supporting IPv6 is roughly as difficult as supporting IPv4. =20
>=20
> What needs to happen to convert code is all variables either need
> a per network namespace instance or the data structures needs to be
> modified to have a network namespace tag.  For hash tables which
> are hard to allocate dynamically tagging is the preferred conversion
> method, for anything that is small enough duplication is preferred
> as it allows the existing logic to be kept.
>=20
> In the fast path the impact of all of the conversions should be very =
light,
> to non-existent.  In network stack initialization and cleanup there
> is work todo because you are initializing and cleanup variables more =
often
> then at module insertion and removal.
>=20
> So my expectation is that once we get a framework established and mer=
ged
> to allow network namespaces eventually the entire network stack will =
be
> converted.  Not just ipv4 and ipv6 but decnet, ipx, iptables, fair sc=
heduling,
> ethernet bridging and all of the other weird and twisty bits of the
> linux network stack.
Thanks Eric for such descriptive comment. I can only sign off on it :)

>=20
> The primary practical hurdle is there is a lot of networking code in
> the kernel.
>=20
> I think I know a path by which we can incrementally merge support for
> network namespaces without breaking anything.  More to come on this
> when I finish up my demonstration patchset in a week or so that
> is complete enough to show what I am talking about.
>=20
> I hope this helps but the concept into perspective.
I'll be waiting it.=20

>=20
> As for Dmitry's patchset in particular it currently does not support
> IPv6 and I don't know where it is with respect to the broadcast and
> multicast but I don't see any immediate problems that would preclude
> those from working.  But any incompleteness is exactly that
> incompleteness and an implementation problem not a fundamental design
> issue.
Broadcasts/multicasts are supported.

--=20
Thanks,
Dmitry.
