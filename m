From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 01 Apr 2005 23:05:37 +0200
Message-ID: <424DB7A1.8090803@cosmosbay.com>
References: <42370997.6010302@cosmosbay.com>	<20050315103253.590c8bfc.davem@davemloft.net>	<42380EC6.60100@cosmosbay.com>	<20050316140915.0f6b9528.davem@davemloft.net>	<4239E00C.4080309@cosmosbay.com>	<20050331221352.13695124.davem@davemloft.net>	<424D5D34.4030800@cosmosbay.com> <20050401122802.7c71afbc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050401122802.7c71afbc.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
> On Fri, 01 Apr 2005 16:39:48 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20

>>Maybe I should make a static sizing, (replace the 256 constant by somet=
hing based on MAX_CPUS) ?
>=20
>=20
> Even for NR_CPUS, I think the table should be dynamically allocated.
>=20
> It is a goal to eliminate all of these huge arrays in the static
> kernel image, which has grown incredibly too much in recent times.
> I work often to eliminate such things, let's not add new ones :-)

You mean you prefer :

static spinlock_t   *rt_hash_lock ; /* rt_hash_lock =3D alloc_memory_at_b=
oot_time(...) */

instead of

static spinlock_t rt_hash_lock[RT_HASH_LOCK_SZ] ;

In both cases, memory is taken from lowmem, and size of kernel image is r=
oughly the same (bss section takes no space in image)

Then the runtime cost is more expensive in the 'dynamic case' because of =
the extra indirection...

?
