From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 01 Apr 2005 16:39:48 +0200
Message-ID: <424D5D34.4030800@cosmosbay.com>
References: <42370997.6010302@cosmosbay.com>	<20050315103253.590c8bfc.davem@davemloft.net>	<42380EC6.60100@cosmosbay.com>	<20050316140915.0f6b9528.davem@davemloft.net>	<4239E00C.4080309@cosmosbay.com> <20050331221352.13695124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050331221352.13695124.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
> On Thu, 17 Mar 2005 20:52:44 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>=20
>>    - Move the spinlocks out of tr_hash_table[] to a fixed size table :=
 Saves a lot of memory (particulary on UP)
>=20
>=20
> If spinlock_t is a zero sized structure on UP, how can this save memory
> on UP? :-)

Because I deleted the  __attribute__((__aligned__(8))) constraint on stru=
ct rt_hash_bucket.

So sizeof(struct rt_hash_bucket) is now 4 instead of 8 on 32 bits archite=
ctures.

May I remind you some people still use 32 bits CPU ? :-)

By the way I have an updated patch... surviving very serious loads.

>=20
> Anyways, I think perhaps you should dynamically allocate this lock tabl=
e.

Maybe I should make a static sizing, (replace the 256 constant by somethi=
ng based on MAX_CPUS) ?

> Otherwise it looks fine.
>=20
>=20
