From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: Mon, 20 Aug 2007 21:21:18 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E21C6@maui.asicdesigners.com>
References: <20070819.174017.77241227.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com>
	<20070820094317.GA14817@2ka.mipt.ru>
	<8A71B368A89016469F72CD08050AD334018E2115@maui.asicdesigners.com>
	<46C9FAB4.5020609@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, jeff@garzik.org,
	netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>
To: "Patrick Geoffray" <patrick@myri.com>
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
> From: Patrick Geoffray [mailto:patrick@myri.com]
> Sent: Monday, August 20, 2007 1:34 PM
> To: Felix Marti
> Cc: Evgeniy Polyakov; David Miller; sean.hefty@intel.com;
> netdev@vger.kernel.org; rdreier@cisco.com;
> general@lists.openfabrics.org; linux-kernel@vger.kernel.org;
> jeff@garzik.org
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
>=20
> Felix Marti wrote:
> > Yes, the app will take the cache hits when accessing the data.
> However,
> > the fact remains that if there is a copy in the receive path, you
> > require and additional 3x memory BW (which is very significant at
> these
> > high rates and most likely the bottleneck for most current
> systems)...
> > and somebody always has to take the cache miss be it the
copy_to_user
> or
> > the app.
>=20
> The cache miss is going to cost you half the memory bandwidth of a
full
> copy. If the data is already in cache, then the copy is cheaper.
>=20
> However, removing the copy removes the kernel from the picture on the
> receive side, so you lose demultiplexing, asynchronism, security,
> accounting, flow-control, swapping, etc. If it's ok with you to not
use
> the kernel stack, then why expect to fit in the existing
infrastructure
> anyway ?
Many of the things you're referring to are moved to the offload adapter
but from an ease of use point of view, it would be great if the user
could still collect stats the same way, i.e. netstat reports the 4-tuple
in use and other network stats. In addition, security features and
packet scheduling could be integrated so that the user configures them
the same way as the network stack.

>=20
> > Yes, RDMA support is there... but we could make it better and easier
> to
>=20
> What do you need from the kernel for RDMA support beyond HW drivers ?
A
> fast way to pin and translate user memory (ie registration). That is
> pretty much the sandbox that David referred to.
>=20
> Eventually, it would be useful to be able to track the VM space to
> implement a registration cache instead of using ugly hacks in user-
> space
> to hijack malloc, but this is completely independent from the net
> stack.
>=20
> > use. We have a problem today with port sharing and there was a
> proposal
>=20
> The port spaces are either totally separate and there is no issue, or
> completely identical and you should then run your connection manager
in
> user-space or fix your middlewares.
When running on an iWarp device (and hence on top of TCP) I believe that
the port space should shared and i.e. netstat reports the 4-tuple in
use.=20

>=20
> > and not for technical reasons. I believe this email threads shows in
> > detail how RDMA (a network technology) is treated as bastard child
by
> > the network folks, well at least by one of them.
>=20
> I don't think it's fair. This thread actually show how pushy some RDMA
> folks are about not acknowledging that the current infrastructure is
> here for a reason, and about mistaking zero-copy and RDMA.
Zero-copy and RDMA are not the same but in the context of this
discussion I referred to RDMA as a superset (zero-copy is implied).

>=20
> This is a similar argument than the TOE discussion, and it was
> definitively a good decision to not mess up the Linux stack with TOEs.
>=20
> Patrick
