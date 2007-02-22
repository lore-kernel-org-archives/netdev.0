From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 07:06:00 +0100
Message-ID: <45DD32C8.7060902@cosmosbay.com>
References: <200702201209.52388.dada1@cosmosbay.com>	<p73y7mrd6o9.fsf@bingen.suse.de>	<200702211419.30856.dada1@cosmosbay.com>	<20070221.053721.112287244.davem@davemloft.net> <17884.53809.880275.142372@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	johnpol@2ka.mipt.ru, akepner@sgi.com, linux@horizon.com,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:56002 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932698AbXBVGGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 01:06:46 -0500
In-Reply-To: <17884.53809.880275.142372@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Olsson a =E9crit :
> David Miller writes:
>=20
>  > But what about if tree lookup were free :-)
>  >=20
>  > This is why I consider Robert Olsson's trash work the most promisi=
ng,
>  > if we stick sockets into his full flow identified routing cache tr=
ie
>  > entries, we can eliminate lookup altogether.
>  >=20
>  > Just like how he already uses traffic inspection to kill cache ent=
ries
>  > when FIN shutdown sequence is snooped, we can explicitly flush suc=
h
>  > entries when socket is closed fully on local system.
>=20
>  Below is current tree-stats from a "production" flowlogging applicat=
ion at a=20
>  large university (real traffic) using this full flow lookup.
>=20
>  With 100k flows we typically see an aver depth 1.3 and a max depth 4=
=2E Right=20
>  now there is only a dst entry in leaf nodes. So yes anything else we=
 can put=20
>  in leaf is "free".
>=20
> trie:
>         Aver depth:     1.31
>         Max depth:      4
>         Leaves:         99930
>         Internal nodes: 14925
>           1: 13450  2: 1465  3: 9  18: 1
>         Pointers: 294976
> Null ptrs: 180122
> Total size: 7259  kB
>
Hi Robert

This sounds *very* promising.
I read again the pdf presentation and theory seems ok.

However you speak of average depth and max depth without mentioning=20
corresponding cache lines. Are all your structures under L1_CACHE_BYTES=
 ?

Do you have a pointer to the patch so that I can take a look on it and=20
eventually start to think about it ? (ie adding free bits :) )

Thank you
Eric
