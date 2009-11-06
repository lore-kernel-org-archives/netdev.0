From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH net-next] Phonet: use rwlock for sockets list
Date: Fri, 6 Nov 2009 16:29:42 +0200
Message-ID: <200911061629.42911.remi.denis-courmont@nokia.com>
References: <1257514891-18917-1-git-send-email-remi@remlab.net> <65081524fbfeb975c842ebc79a8fb038@chewa.net> <4AF42C07.4050008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:53693 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbZKFO2P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 09:28:15 -0500
In-Reply-To: <4AF42C07.4050008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 06 November 2009 16:00:39 ext Eric Dumazet, you wrote:
> R=C3=A9mi Denis-Courmont a =C3=A9crit :
> > It seems better than a spinlock, assuming that sockets are
> > created/destroyed more seldom than they receive packets. And then
> > sk_for_each_rcu does not exist. I am sure there is a good reason fo=
r
> > that, though I wouldn't know. I guess I should try to use RCU hlist=
_nulls
> > then?
>=20
> spin_lock()/spin_unlock() is faster than read_lock()/read_unlock(), u=
nless
> there is contention.  (two atomic ops instead of one)
>=20
> So, unless you have a particular performance problem, it's actually
> better to use a spinlock.
>=20
> If you do have performance problem, a RCU conversion is better than r=
wlock.
> I can do RCU conversion if you ask me...

The most obvious current bottleneck is the sockets linked-list more so =
than=20
the locking scheme (RCU vs spinlock vs rwlock). I'll fix that soonish=20
regardless of the locking.

Then there is the devices lists. I did not want to clutter all net_devi=
ce's=20
with a Phonet-specific pointer, since most devices aren't Phonet-capabl=
e. So=20
we have a linked-list for per-device data. There, I guess RCU would mak=
e=20
sense, but it did not seem trivial a change at all.

That said, there are no real "problems" yet - I was just trying to impr=
ove=20
things. N900 ships with the 2.6.30 Phonet stack, and it works fine :) T=
he 3G=20
access network is typically the biggest bottleneck anyway...

So if you say R/W locks suck, screw this patch.

Thanks!

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
