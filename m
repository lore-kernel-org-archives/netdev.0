From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH 6/6] fs: Introduce kern_mount_special() to mount
	special vfs
Date: Fri, 28 Nov 2008 09:34:19 +0000
Message-ID: <20081128093419.GM28946@ZenIV.linux.org.uk>
References: <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDCAB.1070204@cosmosbay.com> <20081128092604.GL28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org,
	ink-biIs/Y0ymYJMZLIVYojuPNP0rXTJTi09@public.gmane.org
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081128092604.GL28946-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 28, 2008 at 09:26:04AM +0000, Al Viro wrote:

gyah...  That would be

> static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
> {
> 	unsigned long temp, res;
> 	__asm__ __volatile__(
> 	"1:     ldl_l %0,%1\n"
> 	"       cmpne %0,%4,%2\n"
 	"       beq %2,3f\n"
 	"       addl %0,%3,%2\n"
> 	"       stl_c %2,%1\n"
> 	"       beq %2,2f\n"
> 	"3:\n"
>         ".subsection 2\n"
>         "2:     br 1b\n"
>         ".previous"
>         :"=&r" (temp), "=m" (v->counter), "=&r" (res)
>         :"Ir" (a), "Ir" (u), "m" (v->counter) : "memory");
> 	smp_mb();
> 	return res;
> }
> 
> static __inline__ int atomic64_add_unless(atomic64_t *v, long a, long u)
> {
> 	unsigned long temp, res;
> 	__asm__ __volatile__(
> 	"1:     ldq_l %0,%1\n"
> 	"       cmpne %0,%4,%2\n"
 	"       beq %2,3f\n"
 	"       addq %0,%3,%2\n"
> 	"       stq_c %2,%1\n"
> 	"       beq %2,2f\n"
> 	"3:\n"
>         ".subsection 2\n"
>         "2:     br 1b\n"
>         ".previous"
>         :"=&r" (temp), "=m" (v->counter), "=&r" (res)
>         :"Ir" (a), "Ir" (u), "m" (v->counter) : "memory");
> 	smp_mb();
> 	return res;
> }
> 
> Comments?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
