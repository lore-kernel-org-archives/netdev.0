From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Tue, 05 Oct 2010 16:53:13 +0200
Message-ID: <1286290393.7071.38.camel@firesoul.comx.local>
References: <20101005141833.20929.10943.stgit@localhost>
	 <1286289703.2796.292.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:57148 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623Ab0JEPCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 11:02:24 -0400
In-Reply-To: <1286289703.2796.292.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-10-05 at 16:41 +0200, Eric Dumazet wrote:
> Le mardi 05 octobre 2010 =C3=A0 16:18 +0200, Jesper Dangaard Brouer a=
 =C3=A9crit :
> > Network driver igb: Improve the accuracy of stats in /proc/net/dev,=
 by
> > updating the adapter stats when reading /proc/net/dev.  Currently t=
he
> > stats are updated by the watchdog timer every 2 sec, or when gettin=
g
> > stats via ethtool -S.
> >=20
> > A number of userspace apps read these /proc/net/dev stats every sec=
ond,
> > e.g. ifstat, which then gives a perceived very bursty traffic patte=
rn,
> > which is actually false.
> >=20
> > Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
>=20
> Unfortunately this is racy with igb_watchdog_task()
>=20
> igb_update_stats() must be called under protection of a lock.

Its already racy, because "ethtool -S" reads out the stats immediately,
and thus races with the timer.

See: igb_ethtool.c
 igb_get_ethtool_stats() invoke igb_update_stats(adapter);

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


