From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: route cache DoS testing and softirqs
Date: Wed, 31 Mar 2004 12:36:25 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1080700584.17686.237.camel@bach>
References: <20040329184550.GA4540@in.ibm.com>
	 <20040329222926.GF3808@dualathlon.random>
	 <20040330050614.GA4669@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrea Arcangeli <andrea@suse.de>, Dipankar Sarma <dipankar@in.ibm.com>,
        lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        "Paul E. McKenney" <paulmck@us.ibm.com>,
        Dave Miller <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Andrew Morton <akpm@osdl.org>,
        rusty@au1.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srivatsa Vaddagiri <vatsa@in.ibm.com>
In-Reply-To: <20040330050614.GA4669@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-03-30 at 15:06, Srivatsa Vaddagiri wrote:
> On Tue, Mar 30, 2004 at 01:07:12AM +0000, Andrea Arcangeli wrote:
> > btw, the set_current_state(TASK_INTERRUPTIBLE) before
> > kthread_should_stop seems overkill w.r.t. smp locking, plus the code is
> > written in the wrong way around, all set_current_state are in the wrong
> > place. It's harmless but I cleaned up that bit as well.
> 
> I think set_current_state(TASK_INTERRUPTIBLE) before kthread_should_stop()
> _is_ required, otherwise kthread_stop can fail to destroy a kthread.

The problem is that kthread_stop used to send a signal to the kthread,
which meant we didn't have to beware of races (since it would never
sleep any more): kthread_should_stop() was called signal_pending 8)

Andrew hated the signal mechanism, so I abandoned it, but didn't go back
and fix all the users.  It's tempting to send a signal anyway to make
life simpler, though, although that might set a bad example for others.

Rusty.
-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell
