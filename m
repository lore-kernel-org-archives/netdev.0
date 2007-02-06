From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Mon, 5 Feb 2007 18:18:10 -0800
Message-ID: <20070205181810.bbfbf42c.akpm@linux-foundation.org>
References: <200702060032.l160WErX004652@shell0.pdx.osdl.net>
	<20070205.181026.122835715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Ingo Molnar <mingo@elte.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:44917 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965465AbXBFCSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 21:18:39 -0500
In-Reply-To: <20070205.181026.122835715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Feb 2007 18:10:26 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Mon, 05 Feb 2007 16:31:11 -0800
> 
> > From: Andrew Morton <akpm@osdl.org>
> > 
> > "using smp_processor_id() in preemptible code"
> > 
> > Cc: Patrick McHardy <kaber@trash.net>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> We NAK'd this because every patch in the lockdep trace should
> have preemption disabled because software interrupts ought
> to be disabled in those code paths.
> 
> Someone needs to track down why this is really happening.

I think the finger was pointed at preemptible rcu, in -mm.  iirc, the net
stats code is assuming that rcu_read_lock() disables preemption as a side-effect,
which rcu-preempt makes no-longer-true.

Not sure what to do there.  Perhaps add a new
rcu_read_lock_with_preempt_disable() thing which will dtrt with either
config.
