From: "Kanevsky, Arkady" <Arkady.Kanevsky@netapp.com>
Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3:
	Support"iwarp-only"interfacesto avoid 4-tuple conflicts.
Date: Fri, 28 Sep 2007 16:36:18 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB805187762@exnane01.hq.netapp.com>
References: <20070923203649.8324.64524.stgit@dell3.ogc.int><46FBF8AF.9040700@ichips.intel.com><C98692FD98048C41885E0B0FACD9DFB805187514@exnane01.hq.netapp.com>
	<000101c8013a$41b374f0$a7cc180a@amr.corp.intel.com>
	<C98692FD98048C41885E0B0FACD9DFB80518755A@exnane01.hq.netapp.com>
	<46FD5A2F.7010409@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Steve Wise" <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <46FD5A2F.7010409@opengridcomputing.com>
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

Exactly,
it forces the burden on administrator.
And one will be forced to try one mount for iWARP and it does not
work issue another one TCP or UDP if it fails.
Yack!

And server will need to listen on different IP address and simple
* will not work since it will need to listen in two different domains.

Had we run this proposal by administrators?
Thanks,

Arkady Kanevsky                       email: arkady@netapp.com
Network Appliance Inc.               phone: 781-768-5395
1601 Trapelo Rd. - Suite 16.        Fax: 781-895-1195
Waltham, MA 02451                   central phone: 781-768-5300
=20

> -----Original Message-----
> From: Steve Wise [mailto:swise@opengridcomputing.com]=20
> Sent: Friday, September 28, 2007 3:47 PM
> To: Kanevsky, Arkady
> Cc: Sean Hefty; Sean Hefty; netdev@vger.kernel.org;=20
> rdreier@cisco.com; linux-kernel@vger.kernel.org;=20
> general@lists.openfabrics.org
> Subject: Re: [ofa-general] [PATCH v3] iw_cxgb3:=20
> Support"iwarp-only"interfacesto avoid 4-tuple conflicts.
>=20
>=20
>=20
> Kanevsky, Arkady wrote:
> > Sean,
> > IB aside,
> > it looks like an ULP which is capable of being both RDMA aware and=20
> > RDMA not-aware, like iSER and iSCSI, NFS-RDMA and NFS, SDP and=20
> > sockets, will be treated as two separete ULPs.
> > Each has its own IP address, since there is a different IP=20
> address for=20
> > iWARP port and "regular" Ethernet port. So it falls on the users of=20
> > ULPs to "handle" it via DNS or some other services.
> > Is this "acceptable" to users? I doubt it.
> >=20
> > Recall that ULPs are going in opposite directions by having a=20
> > different port number for RDMA aware and RDMA unaware=20
> versions of the ULP.
> > This way, ULP "connection manager" handles RDMA-ness under=20
> the covers,=20
> > while users plug an IP address for a server to connect to.
> > Thanks,
>=20
> Arkady, I'm confused about how this proposed design changes=20
> the behavior of the ULPs that run on TCP and iWARP.  I don't=20
> see much difference from the point of view of the ULPs.
>=20
> The NFS-RDMA server, for example, will not need to change=20
> since it binds to address 0.0.0.0 which will translate into a=20
> bind/listen on the specific iwarp address for each iwarp=20
> device on the rdma side, and address 0.0.0.0 for the TCP side.
>=20
> Am I missing your point?
>=20
> The real pain, IMO, with this solution is that it FORCES the=20
> admins to use 2 subnets when 1 is sufficient if the net=20
> maintainers would unify the port space...
>=20
> Steve.
>=20
>=20
>=20
> >=20
> > Arkady Kanevsky                       email: arkady@netapp.com
> > Network Appliance Inc.               phone: 781-768-5395
> > 1601 Trapelo Rd. - Suite 16.        Fax: 781-895-1195
> > Waltham, MA 02451                   central phone: 781-768-5300
> > =20
> >=20
> >> -----Original Message-----
> >> From: Sean Hefty [mailto:sean.hefty@intel.com]
> >> Sent: Thursday, September 27, 2007 3:12 PM
> >> To: Kanevsky, Arkady; Sean Hefty; Steve Wise
> >> Cc: netdev@vger.kernel.org; rdreier@cisco.com;=20
> >> linux-kernel@vger.kernel.org; general@lists.openfabrics.org
> >> Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3:=20
> >> Support"iwarp-only"interfacesto avoid 4-tuple conflicts.
> >>
> >>> What is the model on how client connects, say for iSCSI,=20
> when client=20
> >>> and server both support, iWARP and 10GbE or 1GbE, and=20
> would like to=20
> >>> setup "most" performant "connection" for ULP?
> >> For the "most" performance connection, the ULP would use=20
> IB, and all=20
> >> these problems go away.  :)
> >>
> >> This proposal is for each iwarp interface to have its own=20
> IP address. =20
> >> Clients would need an iwarp usable address of the server and would=20
> >> connect using rdma_connect().  If that call (or=20
> >> rdma_resolve_addr/route) fails, the client could try=20
> connecting using=20
> >> sockets, aoi, or some other interface.  I don't see that Steve's=20
> >> proposal changes anything from the client's perspective.
> >>
> >> - Sean
> >> _______________________________________________
> >> general mailing list
> >> general@lists.openfabrics.org
> >> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
> >>
> >> To unsubscribe, please visit
> >> http://openib.org/mailman/listinfo/openib-general
> >>
>=20
