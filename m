From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 9 Mar 2009 13:24:36 -0700
Message-ID: <20090309132436.79456625@nehalam>
References: <20090309112521.GB37984@bts.sk>
	<1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
	<20090309200505.GA58375@bts.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Marian =?UTF-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56158 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752651AbZCIUYl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 16:24:41 -0400
In-Reply-To: <20090309200505.GA58375@bts.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 Mar 2009 21:05:05 +0100
Marian =C4=8Eurkovi=C4=8D <md@bts.sk> wrote:

> On Mon, 9 Mar 2009 11:01:52 -0700, John Heffner wrote
> > On Mon, Mar 9, 2009 at 4:25 AM, Marian =C4=8Eurkovi=C4=8D <md@bts.s=
k> wrote:
> > >   As rx window autotuning is enabled in all recent kernels and wi=
th 1 GB
> > > of RAM the maximum tcp_rmem becomes 4 MB, this problem is spreadi=
ng
> > >   rapidly
> > > and we believe it needs urgent attention. As demontrated above, s=
uch
> > >   huge
> > > rx window (which is at least 100*BDP of the example above) does n=
ot
> > >   deliver
> > > any performance gain but instead it seriously harms other hosts a=
nd/or
> > > applications. It should also be noted, that host with autotuning =
enabled
> > > steals an unfair share of the total available bandwidth, which mi=
ght
> > > look
> > > like a "better" performing TCP stack at first sight - however suc=
h
> > > behaviour
> > > is not appropriate (RFC2914, section 3.2).
> >
> > It's well known that "standard" TCP fills all available drop-tail
> > buffers, and that this behavior is not desirable.
>=20
> Well, in practice that was always limited by receive window size, whi=
ch
> was by default 64 kB on most operating systems. So this undesirable b=
ehavior
> was limited to hosts where receive window was manually increased to h=
uge
> values.
>=20
> Today, the real effect of autotuning is the same as changing the rece=
ive window
> size to 4 MB on *all* hosts, since there's no mechanism to prevent it=
 from
> growing the window to maximum even for low RTT paths.
>=20
> > The situation you describe is exactly what congestion control (the
> > topic of RFC2914) should fix.  It is not the role of receive window
> > (flow control).  It is really the sender's job to detect and react =
to
> > this, not the receiver's.  (We have had this discussion before on
> > netdev.)
>=20
> It's not of high importance whose job it is according to pure theory.
> What matters is, that autotuning introduced serious problem at LAN co=
ntext
> by disabling any possibility to properly react to increasing RTT. Aga=
in,
> it's not important whether this functionality was there by design or =
by
> coincidence, but it was holding the system well-balanced for many yea=
rs.
>=20
> Now, as autotuning is enabled by default in stock kernel, this proble=
m is
> spreading into LANs without users even knowing what's going on. There=
fore
> I'd like to suggest to look for a decent fix which could be implement=
ed
> in relatively short time frame. My proposal is this:
>=20
> - measure RTT during the initial phase of TCP connection (first X seg=
ments)
> - compute maximal receive window size depending on measured RTT using
>   configurable constant representing the bandwidth part of BDP
> - let autotuning do its work upto that limit.
>=20
>   With kind regards,
>=20
>         M.=20

So you have broken infrastructure or senders and you want to blame
the receiver? The receiver is not responsible for flow control in TCP.

