From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Thu, 28 Jul 2005 22:56:32 +0200
Message-ID: <42E94680.8060309@cosmosbay.com>
References: <20050704.160140.21591849.davem@davemloft.net>	<42CA390C.9000801@cosmosbay.com>	<42E8FF24.9070009@cosmosbay.com> <20050728.123922.126777020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050728.123922.126777020.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 28 Jul 2005 17:52:04 +0200
>=20
>=20
>>[NET] : Adds prefetches in route hash list traversals.
>>
>>The actual code doesnt use a prefetch enabled macro like
>>list_for_each_rcu(), so manually add prefetch() hints.
>=20
>=20
> and the measured performance improvement is?
>=20
>=20
Half the improvement we could get if only fl.fl4_dst, and other fields we=
re not so far away from the u.rt_next field. (0xE8 on x86_64)

For good performance, one should of course choose a big route cache hash =
size, and in this case, prefetchs are useless, and even cost an=20
extra load : prefetch(rth->u.rt_next) imply the load of the rt_next point=
er at the start of rth structure, while the fl fields are on a=20
different cache line)

But in case of DDOS, prefetches are a win.

I did not test a solution using two prefetches...

Other patches using prefetches will follow.

Eric
