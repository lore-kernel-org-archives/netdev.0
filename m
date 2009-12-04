From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast delivery
Date: Fri, 4 Dec 2009 02:15:16 +0200
Message-ID: <200912040215.16690.opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <200912040130.54966.opurdila@ixiacom.com> <4B184F4C.3060407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:28024 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754554AbZLDASZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 19:18:25 -0500
In-Reply-To: <4B184F4C.3060407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 December 2009 01:52:44 you wrote:
> Octavian Purdila a =E9crit :

> > Since at this point we are using UP ports contention is not really =
an
> > issue for us. I've extrapolated this (lock per hash bucket) based o=
n how
> > locking is done in other places, like UDP.
>=20
> Yes but you know we want to remove those locks per UDP hash bucket, s=
ince
>  we dont really need them anymore. ;)
>=20
> If you remember, we had in the past one rwlock for the whole UDP tabl=
e.
>=20
> Then this was converted to one spinlock per hash slot (128 slots) + R=
CU
>  lookups for unicast RX
>=20
> Then we dynamically sized udp table at boot (up to 65536 slots)
>=20
> multicast optimization (holding lock for small duration + double hash=
ing)
>=20
> bind optimization (thanks to double hashing)
>=20
> To be done :
>=20
> 1) multicast RX can be done without taking any lock, and RCU lookups
> 2) zap all locks and use one lock, or a small array of hashed spinloc=
ks
>=20

Thanks for the nice summary Eric !

I still have one doubt related to this: we still need locking for creat=
ing and=20
destroying sockets to insert/remove them into/from the hash, RCU can't =
help us=20
here, right?=20

In that case wouldn't spinlock contention become an issue for short liv=
ed=20
connections? Probably not for UDP (or LLC), but for TCP I certainly can=
 think=20
of a few usecases for short lived connections.
