From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Strange CPU load when flushing route cache (kernel 2.6.31.6)
Date: Mon, 23 Nov 2009 13:28:40 +0100
Message-ID: <1258979320.29747.270.camel@jdb-workstation>
References: <1258970332.29747.262.camel@jdb-workstation>
	 <4B0A63FA.5000804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Robert Olsson <robert@herjulf.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:42284 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756950AbZKWM1O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 07:27:14 -0500
In-Reply-To: <4B0A63FA.5000804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-23 at 11:29 +0100, Eric Dumazet wrote:
> Jesper Dangaard Brouer a =C3=A9crit :
> > Hi Eric and netdev,
> >=20
> > I have observed a strange route cache behaviour when I upgraded som=
e
> > of my production Linux routers (1Gbit/s tg3) to kernel 2.6.31.6 (fr=
om
> > kernel 2.6.25.7).
> >=20
> > Every time the route cache is flushed I get a CPU spike (in softirq=
)
> > with a tail.  I have attached some graphs that illustrate the issue
> > (hope vger.kernel.org will allow these attachments...)
> >=20
> >=20
> > I have done some tuning of the route cache:
> >=20
> >  # From /etc/sysctl.conf
> >  #
> >  # Adjusting the route cache flush interval
> >  net/ipv4/route/secret_interval =3D 1200
> >=20
> >  # Limiting the route cache size
> >  # ip_dst_cache slab objects is 256 bytes.
> >  # 2000000 * 256 bytes =3D 512 MB
> >  net/ipv4/route/max_size =3D 2000000
> >=20
> > Boot parameters: "rhash_entries=3D262143 vmalloc=3D256M"
> >=20
> > The rhash_entries is for the route cache hash size.  The vmalloc is
> > needed because I have _very_ large iptables rulesets (and is runnin=
g
> > on a 32-bit kernel, due to old hardware).
> >=20
> > Any thoughs on how to avoid these CPU spikes?
> > Or where the issue occurs in the code?
> >=20
>=20
> Sure, after a flush, we have to rebuild the cache, so extra work is e=
xpected.

But the old 2.6.25.7 do NOT show this behavior... That is the real
issue...

> (We receive a packet, notice the cached entry is obsolete, free it, a=
llocate a new one
> and inert it into cache)
>=20
> If you dont want these spikes, just dont flush cache :)

I did the cache flushing due to some historical issues, that I think yo=
u
did a fix for... Guess I can drop the flushing and see if the garbage
collection can keep up...

> Do you run a 2G/2G User/Kernel split kernel ?

Not sure, how do I check?

I do use a 32-bit kernel (due to the production machines runs an old
32-bit Slackware OS install and some of the machines cannot run 64-bit)=
=2E

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
