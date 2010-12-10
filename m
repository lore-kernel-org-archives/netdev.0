From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/4] kthread: NUMA aware kthread_create_on_cpu()
Date: Thu, 9 Dec 2010 23:09:37 -0800
Message-ID: <20101209230937.073fab54.akpm@linux-foundation.org>
References: <1290972833.29196.90.camel@edumazet-laptop>
	<20101128224024.GA12300@basil.fritz.box>
	<1290984712.29196.100.camel@edumazet-laptop>
	<20101128230146.GB12300@basil.fritz.box>
	<1290987424.29196.128.camel@edumazet-laptop>
	<20101129090510.GA15763@basil.fritz.box>
	<1291023532.3435.29.camel@edumazet-laptop>
	<1291043695.3435.980.camel@edumazet-laptop>
	<20101209164438.fae1ba4c.akpm@linux-foundation.org>
	<1291960798.2803.18.camel@edumazet-laptop>
	<20101209223210.acd540de.akpm@linux-foundation.org>
	<1291964561.2803.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291964561.2803.25.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2010 08:02:41 +0100 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 09 d__cembre 2010 __ 22:32 -0800, Andrew Morton a __crit :
> 
> > but but but.  The name "kthread_create_on_cpu" sucks.  It's plain wrong.
> 
> Okay you are right Andrew ;) I dont have better idea for the moment.

Dunno.  kthread_create_with_memory_on_node() :)

How's about kthread_create_for_node()?  That's sufficiently vague to
not mislead readers into thinking that it schedules the thread on that
CPU and leaves room in the namespace for a real kthread_create_on_cpu()
(which we could well end up creating).

kthread_create_node_mem()?

> Note that all callers I converted really create one kthread per cpu, not
> per node. They didnt care of node affinity, only me :)
> 
> kthread_create_on_node() seems misleading to me (some cpus run on
> memoryless nodes)

True, but what we're doing here is specifying on which node the
kthread's memory resources should reside - we need to do that even for
CPUs which live on memoryless nodes.
