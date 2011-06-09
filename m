From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: remove unused list
Date: Thu, 09 Jun 2011 05:47:34 +0200
Message-ID: <1307591254.3980.32.camel@edumazet-laptop>
References: <1307513916.3102.23.camel@edumazet-laptop>
	 <1307514470.3102.25.camel@edumazet-laptop>
	 <1307576134.3980.23.camel@edumazet-laptop>
	 <20110608.170557.2273990802892743973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tim.c.chen@linux.intel.com, andi@firstfloor.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44727 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684Ab1FIDri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 23:47:38 -0400
Received: by wwa36 with SMTP id 36so1236759wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 20:47:37 -0700 (PDT)
In-Reply-To: <20110608.170557.2273990802892743973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 juin 2011 =C3=A0 17:05 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 09 Jun 2011 01:35:34 +0200
>=20
> > Andi Kleen and Tim Chen reported huge contention on inetpeer
> > unused_peers.lock, on memcached workload on a 40 core machine, with
> > disabled route cache.
> >=20
> > It appears we constantly flip peers refcnt between 0 and 1 values, =
and
> > we must insert/remove peers from unused_peers.list, holding a conte=
nded
> > spinlock.
> >=20
> > Remove this list completely and perform a garbage collection on-the=
-fly,
> > at lookup time, using the expired nodes we met during the tree
> > traversal.
> >=20
> > This removes a lot of code, makes locking more standard, and obsole=
tes
> > two sysctls (inet_peer_gc_mintime and inet_peer_gc_maxtime). This a=
lso
> > removes two pointers in inet_peer structure.
> >=20
> > There is still a false sharing effect because refcnt is in first ca=
che
> > line of object [were the links and keys used by lookups are located=
], we
> > might move it at the end of inet_peer structure to let this first c=
ache
> > line mostly read by cpus.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Didn't expect you to implement this so fast :-)
>=20
> Applied, thanks!

Thanks David

I would be glad to hear about numbers from Andi and Tim, I am very
jealous of their 80 Threads machine ;)



