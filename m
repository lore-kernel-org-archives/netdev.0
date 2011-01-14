From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Fri, 14 Jan 2011 15:35:28 +0900
Message-ID: <20110114063528.GB10957@verge.net.au>
References: <20110106093312.GA1564@verge.net.au>
 <1294309362.3074.11.camel@edumazet-laptop>
 <20110106124439.GA17004@verge.net.au>
 <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
 <20110107012356.GA1257@verge.net.au>
 <20110110093155.GB13420@verge.net.au>
 <20110113064718.GA17905@verge.net.au>
 <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
 <20110114045818.GA29738@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110114045818.GA29738@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2011 at 06:58:18AM +0200, Michael S. Tsirkin wrote:
> On Fri, Jan 14, 2011 at 08:41:36AM +0900, Simon Horman wrote:
> > On Thu, Jan 13, 2011 at 10:45:38AM -0500, Jesse Gross wrote:
> > > On Thu, Jan 13, 2011 at 1:47 AM, Simon Horman <horms@verge.net.au=
> wrote:
> > > > On Mon, Jan 10, 2011 at 06:31:55PM +0900, Simon Horman wrote:
> > > >> On Fri, Jan 07, 2011 at 10:23:58AM +0900, Simon Horman wrote:
> > > >> > On Thu, Jan 06, 2011 at 05:38:01PM -0500, Jesse Gross wrote:
> > > >> >
> > > >> > [ snip ]
> > > >> > >
> > > >> > > I know that everyone likes a nice netperf result but I agr=
ee with
> > > >> > > Michael that this probably isn't the right question to be =
asking. =C2=A0I
> > > >> > > don't think that socket buffers are a real solution to the=
 flow
> > > >> > > control problem: they happen to provide that functionality=
 but it's
> > > >> > > more of a side effect than anything. =C2=A0It's just that =
the amount of
> > > >> > > memory consumed by packets in the queue(s) doesn't really =
have any
> > > >> > > implicit meaning for flow control (think multiple physical=
 adapters,
> > > >> > > all with the same speed instead of a virtual device and a =
physical
> > > >> > > device with wildly different speeds). =C2=A0The analog in =
the physical
> > > >> > > world that you're looking for would be Ethernet flow contr=
ol.
> > > >> > > Obviously, if the question is limiting CPU or memory consu=
mption then
> > > >> > > that's a different story.
> > > >> >
> > > >> > Point taken. I will see if I can control CPU (and thus memor=
y) consumption
> > > >> > using cgroups and/or tc.
> > > >>
> > > >> I have found that I can successfully control the throughput us=
ing
> > > >> the following techniques
> > > >>
> > > >> 1) Place a tc egress filter on dummy0
> > > >>
> > > >> 2) Use ovs-ofctl to add a flow that sends skbs to dummy0 and t=
hen eth1,
> > > >> =C2=A0 =C2=A0this is effectively the same as one of my hacks t=
o the datapath
> > > >> =C2=A0 =C2=A0that I mentioned in an earlier mail. The result i=
s that eth1
> > > >> =C2=A0 =C2=A0"paces" the connection.
>=20
> This is actually a bug. This means that one slow connection will affe=
ct
> fast ones. I intend to change the default for qemu to sndbuf=3D0 : th=
is
> will fix it but break your "pacing". So pls do not count on this
> behaviour.

Do you have a patch I could test?

> > > > Further to this, I wonder if there is any interest in providing
> > > > a method to switch the action order - using ovs-ofctl is a hack=
 imho -
> > > > and/or switching the default action order for mirroring.
> > >=20
> > > I'm not sure that there is a way to do this that is correct in th=
e
> > > generic case.  It's possible that the destination could be a VM w=
hile
> > > packets are being mirrored to a physical device or we could be
> > > multicasting or some other arbitrarily complex scenario.  Just th=
ink
> > > of what a physical switch would do if it has ports with two diffe=
rent
> > > speeds.
> >=20
> > Yes, I have considered that case. And I agree that perhaps there
> > is no sensible default. But perhaps we could make it configurable s=
omehow?
>=20
> The fix is at the application level. Run netperf with -b and -w flags=
 to
> limit the speed to a sensible value.

Perhaps I should have stated my goals more clearly.
I'm interested in situations where I don't control the application.

