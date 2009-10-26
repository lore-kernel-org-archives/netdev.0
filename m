From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 08:48:03 +0100
Message-ID: <4AE55433.6060509@gmail.com>
References: <200910252158.53921.opurdila@ixiacom.com>	<4AE4C1FA.7000002@gmail.com> <20091025233016.6860d9c7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43259 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbZJZHsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 03:48:05 -0400
In-Reply-To: <20091025233016.6860d9c7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> I overkilled this with more functions and compared filenames as well.
>=20
>=20
> genarated names (dummyNNNN)
> Algorithm             Time (us)     Ratio       Max   StdDev
> kr_hash                  277925   152408.6   468448 543.19
> string_hash31            329356     5859.4    16042  44.18
> SuperFastHash            324570     4885.9    10502   2.29
> djb2                     327908     5608.5    15210  38.08
> string_hash17            326769     4883.6     9896   0.76
> full_name_hash           343196    63921.0   140628 343.62
> jhash_string             463801     4883.8    10085   1.02
> sdbm                     398587     9801.7    29634  99.18
>=20
> filesystem names
> Algorithm             Time (us)     Ratio       Max   StdDev
> kr_hash                  278840   152314.9   468717 543.01
> string_hash31            331206     5802.1    16004  42.87
> SuperFastHash            325938     4887.5    13528   2.88
> djb2                     330621     5607.1    15333  38.05
> string_hash17            331181     4884.9    13274   1.78
> full_name_hash           347312    63972.2   141336 343.77
> jhash_string             466799     4885.2    13275   1.92
> sdbm                     403691     9771.7    29629  98.88
>=20
> Ratio is the average number of buckets examined when scanning
> the whole set of names.
>=20
>=20
> 1) Increased hash buckets to 1024 which seems reasonable if we are
>    going to test that many names.
> 2) Increased name size to 256 so that longer filenames could be
>    checked and name blocks were not in same cache line
>=20
> * SuperFastHash is too big to put inline
>=20
>=20

Thanks Stephen

1) dcache hash is very big on average machines.

2) dcache : We hash last component, against its parent, acting as a bas=
e.
   Your hashtest program considers the name as a single entity, giving =
different
   hash distribution.

3) netdev names are special, since we have only one parent, and
 smaller hash table.

4) jhash is not that expensive, but it might be because of huge working=
 set of your
test program : strings are not in cpu caches and speed is mostly driven=
 by ram bandwidth.

But current full_name_hash() seems a pretty bad choice !
