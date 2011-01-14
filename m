From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Fri, 14 Jan 2011 06:58:18 +0200
Message-ID: <20110114045818.GA29738@redhat.com>
References: <20110106093312.GA1564@verge.net.au>
 <1294309362.3074.11.camel@edumazet-laptop>
 <20110106124439.GA17004@verge.net.au>
 <AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
 <20110107012356.GA1257@verge.net.au>
 <20110110093155.GB13420@verge.net.au>
 <20110113064718.GA17905@verge.net.au>
 <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
 <20110113234135.GC8426@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941Ab1ANE6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 23:58:53 -0500
Content-Disposition: inline
In-Reply-To: <20110113234135.GC8426@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 08:41:36AM +0900, Simon Horman wrote:
> On Thu, Jan 13, 2011 at 10:45:38AM -0500, Jesse Gross wrote:
> > On Thu, Jan 13, 2011 at 1:47 AM, Simon Horman <horms@verge.net.au> =
wrote:
> > > On Mon, Jan 10, 2011 at 06:31:55PM +0900, Simon Horman wrote:
> > >> On Fri, Jan 07, 2011 at 10:23:58AM +0900, Simon Horman wrote:
> > >> > On Thu, Jan 06, 2011 at 05:38:01PM -0500, Jesse Gross wrote:
> > >> >
> > >> > [ snip ]
> > >> > >
> > >> > > I know that everyone likes a nice netperf result but I agree=
 with
> > >> > > Michael that this probably isn't the right question to be as=
king. =A0I
> > >> > > don't think that socket buffers are a real solution to the f=
low
> > >> > > control problem: they happen to provide that functionality b=
ut it's
> > >> > > more of a side effect than anything. =A0It's just that the a=
mount of
> > >> > > memory consumed by packets in the queue(s) doesn't really ha=
ve any
> > >> > > implicit meaning for flow control (think multiple physical a=
dapters,
> > >> > > all with the same speed instead of a virtual device and a ph=
ysical
> > >> > > device with wildly different speeds). =A0The analog in the p=
hysical
> > >> > > world that you're looking for would be Ethernet flow control=
=2E
> > >> > > Obviously, if the question is limiting CPU or memory consump=
tion then
> > >> > > that's a different story.
> > >> >
> > >> > Point taken. I will see if I can control CPU (and thus memory)=
 consumption
> > >> > using cgroups and/or tc.
> > >>
> > >> I have found that I can successfully control the throughput usin=
g
> > >> the following techniques
> > >>
> > >> 1) Place a tc egress filter on dummy0
> > >>
> > >> 2) Use ovs-ofctl to add a flow that sends skbs to dummy0 and the=
n eth1,
> > >> =A0 =A0this is effectively the same as one of my hacks to the da=
tapath
> > >> =A0 =A0that I mentioned in an earlier mail. The result is that e=
th1
> > >> =A0 =A0"paces" the connection.

This is actually a bug. This means that one slow connection will
affect fast ones. I intend to change the default for qemu to sndbuf=3D0=
 :
this will fix it but break your "pacing". So pls do not count on this b=
ehaviour.

> > > Further to this, I wonder if there is any interest in providing
> > > a method to switch the action order - using ovs-ofctl is a hack i=
mho -
> > > and/or switching the default action order for mirroring.
> >=20
> > I'm not sure that there is a way to do this that is correct in the
> > generic case.  It's possible that the destination could be a VM whi=
le
> > packets are being mirrored to a physical device or we could be
> > multicasting or some other arbitrarily complex scenario.  Just thin=
k
> > of what a physical switch would do if it has ports with two differe=
nt
> > speeds.
>=20
> Yes, I have considered that case. And I agree that perhaps there
> is no sensible default. But perhaps we could make it configurable som=
ehow?

The fix is at the application level. Run netperf with -b and -w flags t=
o
limit the speed to a sensible value.

--=20
MST
