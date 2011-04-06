From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 32772] New: PROBLEM: kernel BUG at
 net/ipv4/inetpeer.c:386
Date: Wed, 06 Apr 2011 18:05:23 +0200
Message-ID: <1302105923.3209.103.camel@edumazet-laptop>
References: <20110406081818.4f0489b5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dimetrios@gmail.com,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38161 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358Ab1DFQFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 12:05:41 -0400
Received: by mail-wy0-f174.google.com with SMTP id 21so1434323wya.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 09:05:40 -0700 (PDT)
In-Reply-To: <20110406081818.4f0489b5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 08:18 -0700, Stephen Hemminger a =C3=A9=
crit :
>=20
> Begin forwarded message:
>=20
> Date: Wed, 6 Apr 2011 07:39:54 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 32772] New: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:=
386
>=20
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D32772
>=20
>            Summary: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: dimetrios@gmail.com
>         Regression: No
>=20
>=20
> Kernel oopses periodically with 'kernel BUG at net/ipv4/inetpeer.c:38=
6'
> message. Machine is used as BGP router and runs Quagga. Nonordinary k=
ernel
> config option set: CONFIG_IP_FIB_TRIE=3Dy.
> Two traces:
> --------------------trace begin--------------
> [625279.329241] kernel BUG at net/ipv4/inetpeer.c:386!

Hmm...

        if (atomic_cmpxchg(&p->refcnt, 1, -1) =3D=3D 1) {
                struct inet_peer __rcu **stack[PEER_MAXDEPTH];
                struct inet_peer __rcu ***stackptr, ***delp;
                if (lookup(&p->daddr, stack, base) !=3D p)
                        BUG();

So we cant find a peer in AVL tree, while we really should at this stag=
e.


This reminds me a possible memory corruption (from another layer)

Could Dmitry try to boot with boot parameter "slub_nomerge" , to make s=
ure
inetpeer layer doesnt share its kmem_cache with a corrupter ?



