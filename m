From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: route cache DoS testing and softirqs
Date: Wed, 31 Mar 2004 23:31:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331213109.GR2143@dualathlon.random>
References: <20040329222926.GF3808@dualathlon.random> <200403302005.AAA00466@yakov.inr.ac.ru> <20040330211450.GI3808@dualathlon.random> <20040330133000.098761e2.davem@redhat.com> <20040330213742.GL3808@dualathlon.random> <20040330142210.080dbe38.davem@redhat.com> <20040330224902.GM3808@dualathlon.random> <20040331204611.GC4543@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, paulmck@us.ibm.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Dipankar Sarma <dipankar@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20040331204611.GC4543@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 01, 2004 at 02:16:11AM +0530, Dipankar Sarma wrote:
> I don't do any of this. I just have a separate quiescent state counter
> for softirq RCU. It is incremented for regular quiescent points
> like cswitch, userland, idle loop as well as at the completion
> of each softirq handler. call_rcu_bh() uses its own queues.
> Everything else works like call_rcu().

the point is that you want this counter to increase in every cpu quick,
that's why I was thinking at posting the tasklet, if the counter doesn't
increase from softirq, you fallback in the grace period length of the
non-bh rcu.

maybe the softirq load is so high in all cpus that just the additional
counter will fix it w/o having to post any additional tasklet (I very
much hope so but especially with irq binding I don't see it happening,
however with irq binding you may have a call_rcu_bh_cpuset).  You should
give it a try and see if it just works.
