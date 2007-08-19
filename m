From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: Sun, 19 Aug 2007 12:49:05 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E209C@maui.asicdesigners.com>
References: <000001c7e22e$b7b90f00$29c8180a@amr.corp.intel.com><20070819.002337.06589160.davem@davemloft.net><8A71B368A89016469F72CD08050AD334018E208F@maui.asicdesigners.com>
	<20070819.123212.13769462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: "David Miller" <davem@davemloft.net>
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
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, August 19, 2007 12:32 PM
> To: Felix Marti
> Cc: sean.hefty@intel.com; netdev@vger.kernel.org; rdreier@cisco.com;
> general@lists.openfabrics.org; linux-kernel@vger.kernel.org;
> jeff@garzik.org
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
>=20
> From: "Felix Marti" <felix@chelsio.com>
> Date: Sun, 19 Aug 2007 10:33:31 -0700
>=20
> > I know that you don't agree that TSO has drawbacks, as outlined by
> > Roland, but its history showing something else: the addition of TSO
> > took a fair amount of time and network performance was erratic for
> > multiple kernel revisions and the TSO code is sprinkled across the
> > network stack.
>=20
> This thing you call "sprinkled" is a necessity of any hardware
> offload when it is possible for a packet to later get "steered"
> to a device which cannot perform the offload.
>=20
> Therefore we need a software implementation of TSO so that those
> packets can still get output to the non-TSO-capable device.
>=20
> We do the same thing for checksum offloading.
>=20
> And for free we can use the software offloading mechanism to
> get batching to arbitrary network devices, even those which cannot
> do TSO.
>=20
> What benefits does RDMA infrastructure give to non-RDMA capable
> devices?  None?  I see, that's great.
>=20
> And again the TSO bugs and issues are being overstated and, also for
> the second time, these issues are more indicative of my bad
> programming skills then they are of intrinsic issues of TSO.  The
> TSO implementation was looking for a good design, and it took me
> a while to find it because I personally suck.
>=20
> Face it, stateless offloads are always going to be better in the long
> term.  And this is proven.
>=20
> You RDMA folks really do live in some kind of fantasy land.
[Felix Marti] You're not at all addressing the fact that RDMA does solve
the memory BW problem and stateless offload doesn't. Apart from that, I
don't quite understand your argument with respect to the benefits of the
RDMA infrastructure; what benefits does the TSO infrastructure give the
non-TSO capable devices? Isn't the answer none and yet you added TSO
support?! I don't think that the argument is stateless _versus_ stateful
offload both have their advantages and disadvantages. Stateless offload
does help, i.e. TSO/LRO do improve performance in back-to-back
benchmarks. It seems me that _you_ claim that there is no benefit to
statefull offload and that is where we're disagreeing; there is benefit
and i.e. the much lower memory BW requirements is just one example, yet
an important one. We'll probably never agree but it seems to me that
we're asking only for small changes to the software stack and then we
can give the choice to the end users: they can opt for stateless offload
if it fits the performance needs or for statefull offload if their apps
require the extra boost in performance.
