From: Guenter Roeck <guenter.roeck@ericsson.com>
Subject: Re: [RFC] [PATCH] Improve hash function used for full_name_hash()
Date: Mon, 04 Jan 2010 12:53:54 -0800
Message-ID: <1262638434.8178.259.camel@groeck-laptop>
References: <1262635784.8178.253.camel@groeck-laptop>
	 <4B42531A.6010903@gmail.com>
Reply-To: guenter.roeck@ericsson.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgate.redback.com ([155.53.3.41]:55199 "EHLO mgate.redback.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587Ab0ADUwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 15:52:19 -0500
In-Reply-To: <4B42531A.6010903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Never mind - my kernel had missed the commit below. I agree, this is no=
w
good enough.

Thanks,
Guenter

On Mon, 2010-01-04 at 15:44 -0500, Eric Dumazet wrote:
> Le 04/01/2010 21:09, Guenter Roeck a =C3=A9crit :
> > Please comment on this proposed patch. It is similar but more gener=
ic than=20
> > a previously proposed change to dev_name_hash() which tried to addr=
ess=20
> > the same problem.
> >=20
> > The hash function currently used for full_name_hash() produces a la=
rge number
> > of collisions if hashed names are similar. This can cause performan=
ce problems
> > if a large number of similar names exist in the kernel (e.g., if th=
ere is
> > a large number of virtual interfaces).
> >=20
> > For example, when hashing "eth0" .. "eth9999" with a hash table siz=
e of 256,
> > the resulting minimum hash bucket depth is 0, the maximum depth is =
563,
> > and the standard deviation is ~136.
> >=20
>=20
> I would be very surprised, since we worked quite a lot on this subjec=
t some months ago...
>=20
> Which tree are you using ?
>=20
> This is not true since commit 08e9897d512fe7a67e46209543b3815b57a36dc=
7
> (netdev: fold name hash properly (v3))
> Date:   Tue Nov 10 07:20:34 2009 +0000
>=20
> Here is actual hash distribution for (eth0 -> eth9999)=20
>=20
> 37 37 36 49 43 36 36 44 35 27 36 45 38 42 52 49
> 51 40 52 43 33 29 41 42 40 47 51 51 47 47 46 41
> 29 34 41 43 41 46 51 52 46 43 48 36 30 34 46 39
> 43 49 53 51 42 51 41 33 28 44 42 38 44 54 51 45
> 46 48 39 29 36 35 33 33 44 43 40 37 45 37 28 23
> 30 36 30 44 42 43 44 37 40 35 26 28 34 35 34 37
> 44 43 44 37 41 33 21 27 36 33 33 34 35 39 27 34
> 37 28 25 32 36 31 40 43 43 45 39 40 33 24 26 34
> 35 39 38 42 45 41 36 39 36 31 33 43 42 44 49 49
> 56 42 46 43 36 28 40 44 39 43 50 54 46 43 48 43
> 30 32 42 42 42 47 53 51 46 44 48 35 30 36 44 37
> 47 49 49 53 41 49 42 35 29 40 42 43 43 51 52 49
> 43 47 43 28 32 35 37 34 38 44 44 34 42 43 27 21
> 29 39 31 40 43 47 40 36 43 34 25 27 36 34 34 36
> 46 44 42 39 41 32 22 27 35 35 32 35 35 39 27 33
> 35 31 24 31 38 31 36 41 47 46 35 41 37 23 23 36
>=20
> This seems good enough.

