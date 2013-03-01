From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] lglock: add read-preference local-global rwlock
Date: Fri, 1 Mar 2013 09:53:49 -0800
Message-ID: <20130301175349.GC2481@mtj.dyndns.org>
References: <512BBAD8.8010006@linux.vnet.ibm.com>
 <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com>
 <512C7A38.8060906@linux.vnet.ibm.com>
 <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com>
 <512CC509.1050000@linux.vnet.ibm.com>
 <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com>
 <512D0D67.9010609@linux.vnet.ibm.com>
 <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com>
 <512E7879.20109@linux.vnet.ibm.com>
 <5130E8E2.50206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	Lai Jiangshan <eag0628@gmail.com>,
	Michel Lespinasse <walken@google.com>,
	linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	namhyung@kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5130E8E2.50206@cn.fujitsu.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey, guys and Oleg (yes, I'm singling you out ;p because you're that
awesome.)

On Sat, Mar 02, 2013 at 01:44:02AM +0800, Lai Jiangshan wrote:
> Performance:
> We only focus on the performance of the read site. this read site's fast path
> is just preempt_disable() + __this_cpu_read/inc() + arch_spin_trylock(),
> It has only one heavy memory operation. it will be expected fast.
> 
> We test three locks.
> 1) traditional rwlock WITHOUT remote competition nor cache-bouncing.(opt-rwlock)
> 2) this lock(lgrwlock)
> 3) V6 percpu-rwlock by "Srivatsa S. Bhat". (percpu-rwlock)
>    (https://lkml.org/lkml/2013/2/18/186)
> 
> 		nested=1(no nested)	nested=2	nested=4
> opt-rwlock	 517181			1009200		2010027
> lgrwlock	 452897			 700026		1201415
> percpu-rwlock	1192955			1451343		1951757

On the first glance, the numbers look pretty good and I kinda really
like the fact that if this works out we don't have to introduce yet
another percpu synchronization construct and get to reuse lglock.

So, Oleg, can you please see whether you can find holes in this one?

Srivatsa, I know you spent a lot of time on percpu_rwlock but as you
wrote before Lai's work can be seen as continuation of yours, and if
we get to extend what's already there instead of introducing something
completely new, there's no reason not to (and my apologies for not
noticing the possibility of extending lglock before).  So, if this can
work, it would be awesome if you guys can work together.  Lai might
not be very good at communicating in english yet but he's really good
at spotting patterns in complex code and playing with them.

Thanks!

-- 
tejun
