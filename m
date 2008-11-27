From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH 0/6] fs: Scalability of sockets/pipes allocation/deallocation
 on SMP
Date: Thu, 27 Nov 2008 07:27:59 +0100
Message-ID: <492E3DEF.8030602@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com> <Pine.LNX.4.64.0811261935330.31159@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0811261935330.31159-dRBSpnHQED8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter a =E9crit :
> On Thu, 27 Nov 2008, Eric Dumazet wrote:
>=20
>> The last point is about SLUB being hit hard, unless we
>> use slub_min_order=3D3 at boot, or we use Christoph Lameter
>> patch (struct file RCU optimizations)
>> http://thread.gmane.org/gmane.linux.kernel/418615
>>
>> If we boot machine with slub_min_order=3D3, SLUB overhead disappears=
=2E
>=20
>=20
> I'd rather not be that drastic. Did you try increasing slub_min_objec=
ts
> instead? Try 40-100. If we find the right number then we should updat=
e
> the tuning to make sure that it pickes the right slab page sizes.
>=20
>=20

4096/192 =3D 21

with slub_min_objects=3D22 :

# cat /sys/kernel/slab/filp/order
1
# time ./socket8
real    0m1.725s
user    0m0.685s
sys     0m12.955s

with slub_min_objects=3D45 :

# cat /sys/kernel/slab/filp/order
2
# time ./socket8
real    0m1.652s
user    0m0.694s
sys     0m12.367s

with slub_min_objects=3D80 :

# cat /sys/kernel/slab/filp/order
3
# time ./socket8
real    0m1.642s
user    0m0.719s
sys     0m12.315s

I would say slub_min_objects=3D45 is the optimal value on 32bit arches =
to
get acceptable performance on this workload (order=3D2 for filp kmem_ca=
che)

Note : SLAB here is disastrous, but you already knew that :)

real    0m8.128s
user    0m0.748s
sys     1m3.467s
