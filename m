From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Tue, 17 Jun 2008 11:27:06 +0200
Message-ID: <20080617092706.GB20621@elte.hu>
References: <20080617.003832.130616157.davem@davemloft.net>
	<20080617080958.GC12535@elte.hu> <20080617083220.GA11393@elte.hu>
	<20080617.020840.169830916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl,
	mcmanus@ducksong.com, ilpo.jarvinen@helsinki.fi,
	kuznet@ms2.inr.ac.ru, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080617.020840.169830916.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 17 Jun 2008 10:32:20 +0200
> 
> > those up to 1000 msec delays can be 'felt' via ssh too, if this 
> > problem triggers then the system is almost unusable via the network. 
> > Local latencies are perfect so it's an e1000 problem.
> 
> Or some kind of weird interrupt problem.
> 
> Such an interrupt level bug would also account for the TX timeout's 
> you're seeing btw.

when i originally reported it i debugged it back to missing e1000 TX 
completion IRQs. I tried various versions of the driver to figure out 
whether new workarounds for e1000 cover it but it was fruitless. There 
is a 1000 msec internal watchdog timer IRQ within e1000 that gets things 
going if it's stuck.

But the line sch_generic.c:222 problem is new. It could be an 
escallation of this same problem - not even the hw-internal watchdog 
timeout fixing up things? So basically two levels of completion failed, 
the third fallback level (a hard reset of the interface) helped things 
get going. High score from me for networking layer robustness :-)

	Ingo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
