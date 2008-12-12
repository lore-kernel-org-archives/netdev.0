From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH v3 2/7] fs: Use a percpu_counter to track nr_inodes
Date: Fri, 12 Dec 2008 06:11:11 +0100
Message-ID: <4941F26F.5030902@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com> <4941968E.3020201@cosmosbay.com> <200707241130.56767.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org >> Kernel Testers List"
	<kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200707241130.56767.nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Nick Piggin a =E9crit :
> On Friday 12 December 2008 09:39, Eric Dumazet wrote:
>> Avoids cache line ping pongs between cpus and prepare next patch,
>> because updates of nr_inodes dont need inode_lock anymore.
>>
>> (socket8 bench result : no difference at this point)
>=20
> Looks good.
>=20
> But.... If we never actually need fast access to the approximate
> total, (which seems to apply to this and the previous patch) we
> could use something much simpler which does not have the spinlock
> or all this batching stuff that percpu counters have. I'd prefer
> that because it will be faster in a straight line...

Well, using a non batching mode could be real easy, just
call __percpu_counter_add(&counter, inc, 1<<30);

Or define a new percpu_counter_fastadd(&counter, inc);

percpu_counter are nice because handle the CPU hotplug problem,
if we want to use for_each_online_cpu() instead of
for_each_possible_cpu().

>=20
> (BTW. percpu counters can't be used in interrupt context? That's
> nice.)
>=20
>=20

Not sure why you said this.

I would like to have a irqsafe percpu_counter, I was preparing such a
patch because we need it for net-next
