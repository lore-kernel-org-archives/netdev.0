From: Thomas Fjellstrom <thomas@fjellstrom.ca>
Subject: Re: [PATCH v2 3/4] kthread: NUMA aware kthread_create_on_cpu()
Date: Sun, 12 Dec 2010 23:26:05 -0700
Message-ID: <201012122326.05966.thomas@fjellstrom.ca>
References: <1290972833.29196.90.camel@edumazet-laptop> <1291964561.2803.25.camel@edumazet-laptop> <20101209230937.073fab54.akpm@linux-foundation.org>
Reply-To: thomas@fjellstrom.ca
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101209230937.073fab54.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On December 10, 2010, Andrew Morton wrote:
> On Fri, 10 Dec 2010 08:02:41 +0100 Eric Dumazet <eric.dumazet@gmail.com> 
wrote:
> > Le jeudi 09 d__cembre 2010 __ 22:32 -0800, Andrew Morton a __crit :
> > > but but but.  The name "kthread_create_on_cpu" sucks.  It's plain
> > > wrong.
> > 
> > Okay you are right Andrew ;) I dont have better idea for the moment.
> 
> Dunno.  kthread_create_with_memory_on_node() :)
> 
> How's about kthread_create_for_node()?  That's sufficiently vague to
> not mislead readers into thinking that it schedules the thread on that
> CPU and leaves room in the namespace for a real kthread_create_on_cpu()
> (which we could well end up creating).
> 
> kthread_create_node_mem()?

Just a kernel newb here, how about kthread_create_from_cpu ? unless that has 
some connotations I'm not aware of.

> > Note that all callers I converted really create one kthread per cpu, not
> > per node. They didnt care of node affinity, only me :)
> > 
> > kthread_create_on_node() seems misleading to me (some cpus run on
> > memoryless nodes)
> 
> True, but what we're doing here is specifying on which node the
> kthread's memory resources should reside - we need to do that even for
> CPUs which live on memoryless nodes.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-- 
Thomas Fjellstrom
thomas@fjellstrom.ca
