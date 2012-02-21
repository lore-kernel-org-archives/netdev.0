From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] neighbour: Fixed race condition at tbl->nht
Date: Tue, 21 Feb 2012 16:29:05 -0500 (EST)
Message-ID: <20120221.162905.83071433719723123.davem@davemloft.net>
References: <1329858253.2563.51.camel@Thor>
	<1329859522.18384.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michel@digirati.com.br, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60806 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab2BUV3M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:29:12 -0500
In-Reply-To: <1329859522.18384.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 22:25:22 +0100

> Le mardi 21 f=E9vrier 2012 =E0 16:04 -0500, Michel Machado a =E9crit =
:
>> When the fixed race condition happens:
>>=20
>> 1. While function neigh_periodic_work scans the neighbor hash table
>> pointed by field tbl->nht, it unlocks and locks tbl->lock between
>> buckets in order to call cond_resched.
>>=20
>> 2. Assume that function neigh_periodic_work calls cond_resched, that=
 is,
>> the lock tbl->lock is available, and function neigh_hash_grow runs.
>>=20
>> 3. Once function neigh_hash_grow finishes, and RCU calls
>> neigh_hash_free_rcu, the original struct neigh_hash_table that funct=
ion
>> neigh_periodic_work was using doesn't exist anymore.
>>=20
>> 4. Once back at neigh_periodic_work, whenever the old struct
>> neigh_hash_table is accessed, things can go badly.
>>=20
>> Signed-off-by: Michel Machado <michel@digirati.com.br>
 ...
> Nice catch !
>=20
> Bug introduced in 2.6.37 in commit d6bf781712a (net neigh: RCU
> conversion of neigh hash table)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, and queued up for -stable, thanks.
