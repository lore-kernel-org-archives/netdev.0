From: "Kanevsky, Arkady" <Arkady.Kanevsky@netapp.com>
Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3:
	Support"iwarp-only"interfacesto avoid 4-tuple conflicts.
Date: Thu, 27 Sep 2007 16:19:51 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB80518755A@exnane01.hq.netapp.com>
References: <20070923203649.8324.64524.stgit@dell3.ogc.int><46FBF8AF.9040700@ichips.intel.com><C98692FD98048C41885E0B0FACD9DFB805187514@exnane01.hq.netapp.com>
	<000101c8013a$41b374f0$a7cc180a@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Sean Hefty" <sean.hefty@intel.com>,
	"Sean Hefty" <mshefty@ichips.intel.com>,
	"Steve Wise" <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <000101c8013a$41b374f0$a7cc180a@amr.corp.intel.com>
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

Sean,
IB aside,
it looks like an ULP which is capable of being both RDMA aware and RDMA
not-aware,
like iSER and iSCSI, NFS-RDMA and NFS, SDP and sockets,=20
will be treated as two separete ULPs.
Each has its own IP address, since there is a different IP address for
iWARP
port and "regular" Ethernet port. So it falls on the users of ULPs to
"handle" it
via DNS or some other services.
Is this "acceptable" to users? I doubt it.

Recall that ULPs are going in opposite directions by having a different
port number for RDMA aware and RDMA unaware versions of the ULP.
This way, ULP "connection manager" handles RDMA-ness under the covers,
while users plug an IP address for a server to connect to.
Thanks,

Arkady Kanevsky                       email: arkady@netapp.com
Network Appliance Inc.               phone: 781-768-5395
1601 Trapelo Rd. - Suite 16.        Fax: 781-895-1195
Waltham, MA 02451                   central phone: 781-768-5300
=20

> -----Original Message-----
> From: Sean Hefty [mailto:sean.hefty@intel.com]=20
> Sent: Thursday, September 27, 2007 3:12 PM
> To: Kanevsky, Arkady; Sean Hefty; Steve Wise
> Cc: netdev@vger.kernel.org; rdreier@cisco.com;=20
> linux-kernel@vger.kernel.org; general@lists.openfabrics.org
> Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3:=20
> Support"iwarp-only"interfacesto avoid 4-tuple conflicts.
>=20
> >What is the model on how client connects, say for iSCSI, when client=20
> >and server both support, iWARP and 10GbE or 1GbE, and would like to=20
> >setup "most" performant "connection" for ULP?
>=20
> For the "most" performance connection, the ULP would use IB,=20
> and all these problems go away.  :)
>=20
> This proposal is for each iwarp interface to have its own IP=20
> address.  Clients would need an iwarp usable address of the=20
> server and would connect using rdma_connect().  If that call=20
> (or rdma_resolve_addr/route) fails, the client could try=20
> connecting using sockets, aoi, or some other interface.  I=20
> don't see that Steve's proposal changes anything from the=20
> client's perspective.
>=20
> - Sean
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>=20
> To unsubscribe, please visit=20
> http://openib.org/mailman/listinfo/openib-general
>=20
