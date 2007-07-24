From: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Subject: Re: [PATCH v3 2/7] fs: Use a percpu_counter to track nr_inodes
Date: Tue, 24 Jul 2007 11:30:55 +1000
Message-ID: <200707241130.56767.nickpiggin@yahoo.com.au>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com> <4941968E.3020201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
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
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4941968E.3020201-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 12 December 2008 09:39, Eric Dumazet wrote:
> Avoids cache line ping pongs between cpus and prepare next patch,
> because updates of nr_inodes dont need inode_lock anymore.
>
> (socket8 bench result : no difference at this point)

Looks good.

But.... If we never actually need fast access to the approximate
total, (which seems to apply to this and the previous patch) we
could use something much simpler which does not have the spinlock
or all this batching stuff that percpu counters have. I'd prefer
that because it will be faster in a straight line...

(BTW. percpu counters can't be used in interrupt context? That's
nice.)
