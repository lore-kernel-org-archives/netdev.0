From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Thu, 07 Oct 2010 13:36:00 +0200
Message-ID: <1286451360.6992.32.camel@firesoul.comx.local>
References: <20101005141833.20929.10943.stgit@localhost>
	 <20101006.233611.68115178.davem@davemloft.net>
	 <1286433848.9417.49.camel@edumazet-laptop>
	 <20101006.234611.191419337.davem@davemloft.net>
	 <1286446004.6992.7.camel@firesoul.comx.local>
	 <1286447084.2912.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:55668 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760334Ab0JGLgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 07:36:05 -0400
In-Reply-To: <1286447084.2912.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-07 at 12:24 +0200, Eric Dumazet wrote:
> Le jeudi 07 octobre 2010 =C3=A0 12:06 +0200, Jesper Dangaard Brouer a=
 =C3=A9crit :
> > On Wed, 2010-10-06 at 23:46 -0700, David Miller wrote:
> > > From: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date: Thu, 07 Oct 2010 08:44:08 +0200
> > >=20
> > > > Le mercredi 06 octobre 2010 =C3=A0 23:36 -0700, David Miller a =
=C3=A9crit :
> > > >> From: Jesper Dangaard Brouer <hawk@comx.dk>
> > > >> Date: Tue, 05 Oct 2010 16:18:33 +0200
> > > >>=20
> > > >> > Network driver igb: Improve the accuracy of stats in /proc/n=
et/dev, by
> > > >> > updating the adapter stats when reading /proc/net/dev.  Curr=
ently the
> > > >> > stats are updated by the watchdog timer every 2 sec, or when=
 getting
> > > >> > stats via ethtool -S.
> > > >> >=20
> > > >> > A number of userspace apps read these /proc/net/dev stats ev=
ery second,
> > > >> > e.g. ifstat, which then gives a perceived very bursty traffi=
c pattern,
> > > >> > which is actually false.
> > > >> >=20
> > > >> > Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> > > >>=20
> > > >> I assume that the Intel folks will take care of integrating th=
is
> > > >> now that the locking is fixed.
> > > >=20
> > > > I integrated Jesper patch into my cumulative patch.
> > >=20
> > > Ok.
> >=20
> > I'm fine with this, as long as the commit message describe this cha=
nge
> > of accuracy of stats in /proc/net/dev.
> >=20
> > Something like:
> >=20
> >  This patch also increase the accuracy of stats in /proc/net/dev, b=
y
> >  updating the adapter stats when reading /proc/net/dev.  Previously
> >  the stats were only updated by the watchdog timer every 2 sec, whi=
ch
> >  resulted in false observations from userspace.
> >=20
> >=20
>=20
> Well, its not exactly true :)
>=20
> Previously, igb stats were updated :
> - By watchdog timer, every 2 secs
> - Every time an "ethtool -S ethX" was done
>=20
> There is no general guarantee netdev stats are immediately available =
to
> user.

I'm not talking general, just for this driver.
And I'm not giving any guarantees, that is why I choose the wording
"increase the accuracy" and not "provide accurate stats".

> ndo_get_stats() is not allowed to sleep, (because of bonding...), so
> drivers can not always provide accurate stats, if they need to make a
> long transaction with hardware.
>=20
> Other drivers do the same (provide hardware statistics), with about o=
ne
> second resolution.

Yes, a lot of drivers don't provide accurate states. And one second
resolution, as most drivers use, will usually be good enough for most
admins.

Our usage pattern is a bit different, as we are very interested in
measuring bursty traffic.  I'm explain you why during the Netfilter
Workshop, if I get my talk about IPTV accepted ;-)

I also use the increased accuracy, when running my pktgen testing
scripts.


> So the "resulted in false observations from userspace." is something
> that might upset admins, but is not a hard requirement of netdev stat=
s.

Its definitly not a hard requirement, but lets fix it where we can.

Then change the text:
 "resulted in false observations from userspace"
to:
 "resulted in inaccurate observations from userspace"

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


