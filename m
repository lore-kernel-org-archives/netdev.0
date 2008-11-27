From: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 0/6] fs: Scalability of sockets/pipes allocation/deallocation
 on SMP
Date: Thu, 27 Nov 2008 08:44:41 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0811270838320.13647@quilx.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu>
 <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net>
 <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com>
 <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com>
 <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com>
 <Pine.LNX.4.64.0811261935330.31159@quilx.com> <492E3DEF.8030602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <492E3DEF.8030602-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Nov 2008, Eric Dumazet wrote:

> with slub_min_objects=45 :
>
> # cat /sys/kernel/slab/filp/order
> 2
> # time ./socket8
> real    0m1.652s
> user    0m0.694s
> sys     0m12.367s

That may be a good value. How many processor do you have? Look at
calculate_order() in mm/slub.c:

   if (!min_objects)
                min_objects = 4 * (fls(nr_cpu_ids) + 1);

We couild increase the scaling factor there or start
with a mininum of 20 objects?


Try

	min_objects = 20 + 4 * (fls(nr_cpu_ids) + 1);

> I would say slub_min_objects=45 is the optimal value on 32bit arches to
> get acceptable performance on this workload (order=2 for filp kmem_cache)
>
> Note : SLAB here is disastrous, but you already knew that :)

Its good though to have examples where the queue management gets in the
way of performance.
