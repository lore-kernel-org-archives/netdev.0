From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Thu, 07 Oct 2010 12:24:44 +0200
Message-ID: <1286447084.2912.24.camel@edumazet-laptop>
References: <20101005141833.20929.10943.stgit@localhost>
	 <20101006.233611.68115178.davem@davemloft.net>
	 <1286433848.9417.49.camel@edumazet-laptop>
	 <20101006.234611.191419337.davem@davemloft.net>
	 <1286446004.6992.7.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33382 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882Ab0JGKYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 06:24:49 -0400
Received: by fxm4 with SMTP id 4so240902fxm.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 03:24:48 -0700 (PDT)
In-Reply-To: <1286446004.6992.7.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 octobre 2010 =C3=A0 12:06 +0200, Jesper Dangaard Brouer a =C3=
=A9crit :
> On Wed, 2010-10-06 at 23:46 -0700, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 07 Oct 2010 08:44:08 +0200
> >=20
> > > Le mercredi 06 octobre 2010 =C3=A0 23:36 -0700, David Miller a =C3=
=A9crit :
> > >> From: Jesper Dangaard Brouer <hawk@comx.dk>
> > >> Date: Tue, 05 Oct 2010 16:18:33 +0200
> > >>=20
> > >> > Network driver igb: Improve the accuracy of stats in /proc/net=
/dev, by
> > >> > updating the adapter stats when reading /proc/net/dev.  Curren=
tly the
> > >> > stats are updated by the watchdog timer every 2 sec, or when g=
etting
> > >> > stats via ethtool -S.
> > >> >=20
> > >> > A number of userspace apps read these /proc/net/dev stats ever=
y second,
> > >> > e.g. ifstat, which then gives a perceived very bursty traffic =
pattern,
> > >> > which is actually false.
> > >> >=20
> > >> > Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> > >>=20
> > >> I assume that the Intel folks will take care of integrating this
> > >> now that the locking is fixed.
> > >=20
> > > I integrated Jesper patch into my cumulative patch.
> >=20
> > Ok.
>=20
> I'm fine with this, as long as the commit message describe this chang=
e
> of accuracy of stats in /proc/net/dev.
>=20
> Something like:
>=20
>  This patch also increase the accuracy of stats in /proc/net/dev, by
>  updating the adapter stats when reading /proc/net/dev.  Previously
>  the stats were only updated by the watchdog timer every 2 sec, which
>  resulted in false observations from userspace.
>=20
>=20

Well, its not exactly true :)

Previously, igb stats were updated :
- By watchdog timer, every 2 secs
- Every time an "ethtool -S ethX" was done

There is no general guarantee netdev stats are immediately available to
user.

ndo_get_stats() is not allowed to sleep, (because of bonding...), so
drivers can not always provide accurate stats, if they need to make a
long transaction with hardware.

Other drivers do the same (provide hardware statistics), with about one
second resolution.

So the "resulted in false observations from userspace." is something
that might upset admins, but is not a hard requirement of netdev stats.



