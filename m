From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from
 softirq to workqueue
Date: Fri, 16 Nov 2007 22:23:58 +0100
Message-ID: <473E0A6E.6070808@cosmosbay.com>
References: <20071116174027.726e6eca.dada1@cosmosbay.com> <20071116194959.GE8971@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:56462 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893AbXKPVYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 16:24:12 -0500
In-Reply-To: <20071116194959.GE8971@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman a =E9crit :
> Is it ever neccessary to call cond_resched() if rt_hash_table[i].chai=
n
> is NULL? If not, the following looks cleaner to my eyes:
>=20
> 	for (i =3D 0; i <=3D rt_hash_mask; i++) {
> 		rth =3D rt_hash_table[i].chain;
> 		if (!rth)
> 			continue;
>=20
> 		spin_lock_bh(rt_hash_lock_addr(i));
> 		rth =3D rt_hash_table[i].chain;
> 		rt_hash_table[i].chain =3D NULL;
> 		spin_unlock_bh(rt_hash_lock_addr(i));
>=20
> 		...
>=20

Well, it depends if the table is empty or not, and its size.

Some RT tasks want to to be wakeup every ms for example.

With a 8MB hash table (one million slots on x86_64), the full scan is l=
onger=20
than 1 ms, even if no IRQ came and stole the cpu...

