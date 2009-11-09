From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/8 net-next-2.6] udp: optimisations
Date: Mon, 09 Nov 2009 06:37:24 +0100
Message-ID: <4AF7AA94.6090909@gmail.com>
References: <4AF72738.7020606@gmail.com> <20091108.205522.185944441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lgrijincu@ixiacom.com, opurdila@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38212 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbZKIFh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 00:37:29 -0500
In-Reply-To: <20091108.205522.185944441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :

>=20
> Looks great, all applied, thanks Eric.

Thanks David, I'll make the remaining patches too.

>=20
> I would even go so far as to say that the cutoff to the second hash
> table should be even lower than 10, like maybe 4 or 5.

Probably, but we want to avoid the secondary way if possible,
as this path might have to traverse two different chains.

(total of three cache line accesses to only take a look at chains head/=
count)

Maybe we can change the heuristic to take into account this like that :

if (hslot->count > 4) {
	...
	if (hslot->count < hslot2->count * 2)
		goto begin_primary_hash_lookup;

This is tuning, and needs benchmarking.

