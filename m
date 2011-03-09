From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Wed, 9 Mar 2011 22:33:56 +0100
Message-ID: <20110309213356.GA2898@xanadu.blop.info>
References: <20110308111011.GA27967@xanadu.blop.info>
 <4D764AAC.30302@ncsu.edu>
 <20110308.114346.48506864.davem@davemloft.net>
 <20110308152103.714f5f05@nehalam>
 <4D76D851.4050600@ncsu.edu>
 <20110309065319.GA23740@xanadu.blop.info>
 <20110309095659.1373c296@s6510>
 <20110309182505.GA25272@xanadu.blop.info>
 <20110309120120.5016cab5@nehalam>
 <AANLkTimpLWoSB2H9PObxwK1iGkFBWQZMw=1kTP9BA7qb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Injong Rhee <rhee@ncsu.edu>,
	David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, sangtae.ha@gmail.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:43136 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663Ab1CIVrU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 16:47:20 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimpLWoSB2H9PObxwK1iGkFBWQZMw=1kTP9BA7qb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/11 at 13:12 -0800, Yuchung Cheng wrote:
> On Wed, Mar 9, 2011 at 12:01 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Wed, 9 Mar 2011 19:25:05 +0100
> > Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:
> >
> >> On 09/03/11 at 09:56 -0800, Stephen Hemminger wrote:
> >> > On Wed, 9 Mar 2011 07:53:19 +0100
> >> > Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:
> >> >
> >> > > On 08/03/11 at 20:30 -0500, Injong Rhee wrote:
> >> > > > Now, both tools can be wrong. But that is not catastrophic s=
ince
> >> > > > congestion avoidance can kick in to save the day. In a pipe =
where no
> >> > > > other flows are competing, then exiting slow start too early=
 can
> >> > > > slow things down as the window can be still too small. But t=
hat is
> >> > > > in fact when delays are most reliable. So those tests that s=
ay bad
> >> > > > performance with hystart are in fact, where hystart is suppo=
sed to
> >> > > > perform well.
> >> > >
> >> > > Hi,
> >> > >
> >> > > In my setup, there is no congestion at all (except the buffer =
bloat).
> >> > > Without Hystart, transferring 8 Gb of data takes 9s, with CUBI=
C exiting
> >> > > slow start at ~2000 packets.
> >> > > With Hystart, transferring 8 Gb of data takes 19s, with CUBIC =
exiting
> >> > > slow start at ~20 packets.
> >> > > I don't think that this is "hystart performing well". We could=
 just as
> >> > > well remove slow start completely, and only do congestion avoi=
dance,
> >> > > then.
> >> > >
> >> > > While I see the value in Hystart, it's clear that there are so=
me flaws
> >> > > in the current implementation. It probably makes sense to disa=
ble
> >> > > hystart by default until those problems are fixed.
> >> >
> >> > What is the speed and RTT time of your network?
> >> > I think you maybe blaming hystart for other issues in the networ=
k.
> >>
> >> What kind of issues?
> >>
> >> Host1 is connected through a gigabit ethernet LAN to Router1
> >> Host2 is connected through a gigabit ethernet LAN to Router2
> >> Router1 and Router2 are connected through an experimentation netwo=
rk at
> >> 10 Gb/s
> >> RTT between Host1 and Host2 is 11.3ms.
> >> The network is not congested.
> >
> > By my calculations (1G * 11.3ms) gives BDP of 941 packets which mea=
ns
> > CUBIC would ideally exit slow start at 900 or so packets. Old CUBIC
> > slowstrart of 2000 packets means there is huge overshoot which mean=
s
> > large packet loss burst which would cause a large CPU load on recei=
ver
> > processing SACK.
> It's not clear from Lucas's report that the hystart is exiting when
> cwnd=3D2000 or when sender has sent 2000 packets.
> Lucas could you clarify?

When cwnd is around 2000.
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
