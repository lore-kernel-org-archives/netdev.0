From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: do not use zero refcnt for
 freed entries
Date: Wed, 16 Jun 2010 10:56:49 +0200
Message-ID: <1276678609.2632.13.camel@edumazet-laptop>
References: <1276626194.2541.186.camel@edumazet-laptop>
	 <20100615.142506.02275206.davem@davemloft.net>
	 <1276656324.19249.39.camel@edumazet-laptop>
	 <20100615.214754.42801686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53611 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547Ab0FPI46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 04:56:58 -0400
Received: by wyb40 with SMTP id 40so5473088wyb.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 01:56:56 -0700 (PDT)
In-Reply-To: <20100615.214754.42801686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 21:47 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 16 Jun 2010 04:45:24 +0200
>=20
> > [PATCH net-next-2.6] inetpeer: do not use zero refcnt for freed ent=
ries
> >=20
> > Followup of commit aa1039e73cc2 (inetpeer: RCU conversion)
> >=20
> > Unused inet_peer entries have a null refcnt.
> >=20
> > Using atomic_inc_not_zero() in rcu lookups is not going to work for
> > them, and slow path is taken.
> >=20
> > Fix this using -1 marker instead of 0 for deleted entries.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks Eric.

Thanks

With 65537 peers and a DDOS frag attack, I now get following profiling
results :

-----------------------------------------------------------------------=
------------------
   PerfTop:    1024 irqs/sec  kernel:100.0%  exact:  0.0% [1000Hz
cycles],  (all, cpu: 0)
-----------------------------------------------------------------------=
------------------

             samples  pcnt function                  DSO
             _______ _____ _________________________=20

             7722.00 65.6% inet_frag_find           =20
             1355.00 11.5% ip4_frag_match           =20
              494.00  4.2% __lock_acquire           =20
              260.00  2.2% inet_getpeer             =20
              243.00  2.1% ip_route_input_common    =20
              151.00  1.3% lock_release             =20
              142.00  1.2% mark_lock                =20
              126.00  1.1% lock_acquire             =20
              104.00  0.9% __kmalloc                =20
               86.00  0.7% skb_put                  =20


Just to show what could be the next steps ;)





