From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] Improve hash function used for full_name_hash()
Date: Mon, 04 Jan 2010 21:44:10 +0100
Message-ID: <4B42531A.6010903@gmail.com>
References: <1262635784.8178.253.camel@groeck-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: guenter.roeck@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38279 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767Ab0ADUoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 15:44:13 -0500
In-Reply-To: <1262635784.8178.253.camel@groeck-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/01/2010 21:09, Guenter Roeck a =E9crit :
> Please comment on this proposed patch. It is similar but more generic=
 than=20
> a previously proposed change to dev_name_hash() which tried to addres=
s=20
> the same problem.
>=20
> The hash function currently used for full_name_hash() produces a larg=
e number
> of collisions if hashed names are similar. This can cause performance=
 problems
> if a large number of similar names exist in the kernel (e.g., if ther=
e is
> a large number of virtual interfaces).
>=20
> For example, when hashing "eth0" .. "eth9999" with a hash table size =
of 256,
> the resulting minimum hash bucket depth is 0, the maximum depth is 56=
3,
> and the standard deviation is ~136.
>=20

I would be very surprised, since we worked quite a lot on this subject =
some months ago...

Which tree are you using ?

This is not true since commit 08e9897d512fe7a67e46209543b3815b57a36dc7
(netdev: fold name hash properly (v3))
Date:   Tue Nov 10 07:20:34 2009 +0000

Here is actual hash distribution for (eth0 -> eth9999)=20

37 37 36 49 43 36 36 44 35 27 36 45 38 42 52 49
51 40 52 43 33 29 41 42 40 47 51 51 47 47 46 41
29 34 41 43 41 46 51 52 46 43 48 36 30 34 46 39
43 49 53 51 42 51 41 33 28 44 42 38 44 54 51 45
46 48 39 29 36 35 33 33 44 43 40 37 45 37 28 23
30 36 30 44 42 43 44 37 40 35 26 28 34 35 34 37
44 43 44 37 41 33 21 27 36 33 33 34 35 39 27 34
37 28 25 32 36 31 40 43 43 45 39 40 33 24 26 34
35 39 38 42 45 41 36 39 36 31 33 43 42 44 49 49
56 42 46 43 36 28 40 44 39 43 50 54 46 43 48 43
30 32 42 42 42 47 53 51 46 44 48 35 30 36 44 37
47 49 49 53 41 49 42 35 29 40 42 43 43 51 52 49
43 47 43 28 32 35 37 34 38 44 44 34 42 43 27 21
29 39 31 40 43 47 40 36 43 34 25 27 36 34 34 36
46 44 42 39 41 32 22 27 35 35 32 35 35 39 27 33
35 31 24 31 38 31 36 41 47 46 35 41 37 23 23 36

This seems good enough.
