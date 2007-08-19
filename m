From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: Sun, 19 Aug 2007 10:33:31 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E208F@maui.asicdesigners.com>
References: <adatzqxwh56.fsf@cisco.com><20070817.234405.66176298.davem@davemloft.net><000001c7e22e$b7b90f00$29c8180a@amr.corp.intel.com>
	<20070819.002337.06589160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, rdreier@cisco.com, jeff@garzik.org,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: "David Miller" <davem@davemloft.net>, <sean.hefty@intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: general-bounces@lists.openfabrics.org [mailto:general-
> bounces@lists.openfabrics.org] On Behalf Of David Miller
> Sent: Sunday, August 19, 2007 12:24 AM
> To: sean.hefty@intel.com
> Cc: netdev@vger.kernel.org; rdreier@cisco.com;
> general@lists.openfabrics.org; linux-kernel@vger.kernel.org;
> jeff@garzik.org
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
>=20
> From: "Sean Hefty" <sean.hefty@intel.com>
> Date: Sun, 19 Aug 2007 00:01:07 -0700
>=20
> > Millions of Infiniband ports are in operation today.  Over 25% of
the
> top 500
> > supercomputers use Infiniband.  The formation of the OpenFabrics
> Alliance was
> > pushed and has been continuously funded by an RDMA customer - the US
> National
> > Labs.  RDMA technologies are backed by Cisco, IBM, Intel, QLogic,
> Sun, Voltaire,
> > Mellanox, NetApp, AMD, Dell, HP, Oracle, Unisys, Emulex, Hitachi,
> NEC, Fujitsu,
> > LSI, SGI, Sandia, and at least two dozen other companies.  IDC
> expects
> > Infiniband adapter revenue to triple between 2006 and 2011, and
> switch revenue
> > to increase six-fold (combined revenues of 1 billion).
>=20
> Scale these numbers with reality and usage.
>=20
> These vendors pour in huge amounts of money into a relatively small
> number of extremely large cluster installations.  Besides the folks
> doing nuke and whole-earth simulations at some government lab, nobody
> cares.  And part of the investment is not being done wholly for smart
> economic reasons, but also largely publicity purposes.
>=20
> So present your great Infiniband numbers with that being admitted up
> front, ok?
>=20
> It's relevance to Linux as a general purpose operating system that
> should be "good enough" for %99 of the world is close to NIL.
>=20
> People have been pouring tons of money and research into doing stupid
> things to make clusters go fast, and in such a way that make zero
> sense for general purpose operating systems, for ages.  RDMA is just
> one such example.
[Felix Marti] Ouch, and I believed linux to be a leading edge OS,=20
scaling from small embedded systems to hundreds of CPUs and hence
I assumed that the same 'scalability' applies to the network subsystem.

>=20
> BTW, I find it ironic that you mention memory bandwidth as a retort,
> as Roland's favorite stateless offload devil, TSO, deals explicity
> with lowering the per-packet BUS bandwidth usage of TCP.  LRO
> offloading does likewise.

[Felix Marti] Aren't you confusing memory and bus BW here? - RDMA=20
enables DMA from/to application buffers removing the user-to-kernel/
kernel-to-user memory copy with is a significant overhead at the=20
rates we're talking about: memory copy at 20Gbps (10Gbps in and 10Gbps=20
out) requires 60Gbps of BW on most common platforms. So, receiving and
transmitting at 10Gbps with LRO and TSO requires 80Gbps of system=20
memory BW (which is beyond what most systems can do) whereas RDMA can=20
do with 20Gbps!

In addition, BUS improvements are really not significant (nor are buses=20
the bottleneck anymore with wide availability of PCI-E >=3D x8); TSO
avoids=20
the DMA of a bunch of network headers... a typical example of stateless
offload - improving performance by a few percent while offload
technologies
provide system improvements of hundreds of percent.

I know that you don't agree that TSO has drawbacks, as outlined by
Roland,=20
but its history showing something else: the addition of TSO took a fair
amount of time and network performance was erratic for multiple kernel=20
revisions and the TSO code is sprinkled across the network stack. It is
an=20
example of an intrusive 'improvement' whereas Steve (who started this=20
thread) is asking for a relatively small change (decoupling the 4-tuple=20
allocation from the socket). As Steve has outlined, your refusal of the
change requires RDMA users to work around the issue which pushes the
issue to the end-users and thus slowing down the acceptance of the=20
technology leading to a chicken-and-egg problem: you only care if there=20
are lots of users but you make it hard to use the technology in the
first=20
place, clever ;)
=20
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>=20
> To unsubscribe, please visit
http://openib.org/mailman/listinfo/openib-
> general
