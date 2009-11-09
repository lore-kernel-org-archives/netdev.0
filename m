From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 0/8 net-next-2.6] udp: optimisations
Date: Mon, 9 Nov 2009 17:38:26 +0200
Message-ID: <200911091738.26948.opurdila@ixiacom.com>
References: <4AF72738.7020606@gmail.com> <20091108.205522.185944441.davem@davemloft.net> <4AF7AA94.6090909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lgrijincu@ixiacom.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:2196 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753160AbZKIPl2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 10:41:28 -0500
In-Reply-To: <4AF7AA94.6090909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 09 November 2009 07:37:24 you wrote:
> David Miller a =E9crit :
> > Looks great, all applied, thanks Eric.
>=20
> Thanks David, I'll make the remaining patches too.
>=20
> > I would even go so far as to say that the cutoff to the second hash
> > table should be even lower than 10, like maybe 4 or 5.
>=20
> Probably, but we want to avoid the secondary way if possible,
> as this path might have to traverse two different chains.
>=20
> (total of three cache line accesses to only take a look at chains
>  head/count)
>=20
> Maybe we can change the heuristic to take into account this like that=
 :
>=20
> if (hslot->count > 4) {
> 	...
> 	if (hslot->count < hslot2->count * 2)
> 		goto begin_primary_hash_lookup;
>=20
> This is tuning, and needs benchmarking.
>=20

Eric, thanks a lot !

Lucian is currently testing it on our setup and once we iron out some I=
Pv6=20
issues we are seeing he will follow up with some numbers.
