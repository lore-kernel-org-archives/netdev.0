From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: route cache DoS testing and softirqs
Date: Wed, 31 Mar 2004 13:06:30 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331073630.GA3681@in.ibm.com>
References: <20040329184550.GA4540@in.ibm.com> <20040329222926.GF3808@dualathlon.random> <20040330144324.GA3778@in.ibm.com> <20040330195315.GB3773@in.ibm.com> <20040330204731.GG3808@dualathlon.random> <16489.59080.303710.986410@robur.slu.se>
Reply-To: dipankar@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, "Paul E. McKenney" <paulmck@us.ibm.com>,
        Dave Miller <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16489.59080.303710.986410@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2004 at 11:29:44PM +0200, Robert Olsson wrote:
> Andrea Arcangeli writes:
>  > I see what's going on now, yes my patch cannot help. the workload is
>  > simply generating too much hardirq load, and it's like if we don't use
>  > softirq at all but that we process the packet inside the hardirq for
>  > this matter. As far as RCU is concerned it's like if there a no softirq
>  > at all but that we process everything in the hardirq.
>  > 
>  > so what you're looking after is a new feature then:
>  > 
>  > 1) rate limit the hardirqs
>  > 2) rate limit only part of the irq load (i.e. the softirq, that's handy
>  >    since it's already splitted out) to scheduler-aware context (not
>  >    inside irq context anymore)
>  > 3) stop processing packets in irqs in the first place (NAPI or similar)
> 
>  No Andrea it pure softirq workload. Interfaces runs with irq disabled 
>  at this load w. NAPI. Softirq's are run from spin_unlock_bh etc when 
>  doing route lookup and GC. And the more fine-grained locking we do the 
>  the more do_softirq's are run.

Not lookup, we don't take the lock in lookup. Probably route 
insertions which will happen very frequently in this case.

Thanks
Dipankar
