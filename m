From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: Mon, 20 Aug 2007 09:53:00 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E2115@maui.asicdesigners.com>
References: <20070819.174017.77241227.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com>
	<20070820094317.GA14817@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
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
> From: Evgeniy Polyakov [mailto:johnpol@2ka.mipt.ru]
> Sent: Monday, August 20, 2007 2:43 AM
> To: Felix Marti
> Cc: David Miller; sean.hefty@intel.com; netdev@vger.kernel.org;
> rdreier@cisco.com; general@lists.openfabrics.org; linux-
> kernel@vger.kernel.org; jeff@garzik.org
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
>=20
> On Sun, Aug 19, 2007 at 05:47:59PM -0700, Felix Marti
> (felix@chelsio.com) wrote:
> > [Felix Marti] David and Herbert, so you agree that the user<>kernel
> > space memory copy overhead is a significant overhead and we want to
> > enable zero-copy in both the receive and transmit path? - Yes, copy
>=20
> It depends. If you need to access that data after received, you will
> get
> cache miss and performance will not be much better (if any) that with
> copy.
Yes, the app will take the cache hits when accessing the data. However,
the fact remains that if there is a copy in the receive path, you
require and additional 3x memory BW (which is very significant at these
high rates and most likely the bottleneck for most current systems)...
and somebody always has to take the cache miss be it the copy_to_user or
the app.
>=20
> > avoidance is mainly an API issue and unfortunately the so widely
used
> > (synchronous) sockets API doesn't make copy avoidance easy, which is
> one
> > area where protocol offload can help. Yes, some apps can resort to
> > sendfile() but there are many apps which seem to have trouble
> switching
> > to that API... and what about the receive path?
>=20
> There is number of implementations, and all they are suitable for is
> to have recvfile(), since this is likely the only case, which can work
> without cache.
>=20
> And actually RDMA stack exist and no one said it should be thrown away
> _until_ it messes with main stack. It started to speal ports. What
will
> happen when it gest all port space and no new legal network conection
> can be opened, although there is no way to show to user who got it?
> What will happen if hardware RDMA connection got terminated and
> software
> could not free the port? Will RDMA request to export connection reset
> functions out of stack to drop network connections which are on the
> ports
> which are supposed to be used by new RDMA connections?
Yes, RDMA support is there... but we could make it better and easier to
use. We have a problem today with port sharing and there was a proposal
to address the issue by tighter integration (see the beginning of the
thread) but the proposal got shot down immediately... because it is RDMA
and not for technical reasons. I believe this email threads shows in
detail how RDMA (a network technology) is treated as bastard child by
the network folks, well at least by one of them.
>=20
> RDMA is not a problem, but how it influence to the network stack is.
> Let's better think about how to work correctly with network stack
> (since
> we already have that cr^Wdifferent hardware) instead of saying that
> others do bad work and do not allow shiny new feature to exist.
By no means did I want to imply that others do bad work; are you
referring to me using TSO implementation issues as an example? - If so,
let me clarify: I understand that the TSO implementation took some time
to get right. What I was referring to is that TSO(/LRO) have their own
issues, some eluded to by Roland and me. In fact, customers working on
the LSR couldn't use TSO due to the burstiness it introduces and had to
fall-back to our fine grained packet scheduling done in the offload
device. I am for variety, let us support new technologies that solve
real problems (lots of folks are buying this stuff for a reason) instead
of the 'ah, its brain-dead and has no future' attitude... there is
precedence for offloading the host CPUs: have a look at graphics.
Graphics used to be done by the host CPU and now we have dedicated
graphics adapters that do a much better job... so, why is it so
farfetched that offload devices can do a better job at a data-flow
problem?
>=20
> --
> 	Evgeniy Polyakov
