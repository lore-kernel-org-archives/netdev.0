From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 08:42:13 -0700
Message-ID: <20090428154213.GA10833@linux.vnet.ibm.com>
References: <49F6A8FD.3010804@cosmosbay.com> <20090428.045342.206106171.davem@davemloft.net> <20090428124033.GA1655@elte.hu> <20090428.064340.193569214.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, dada1@cosmosbay.com, torvalds@linux-foundation.org,
	shemminger@vyatta.com, zbr@ioremap.net, peterz@infradead.org,
	mathieu.desnoyers@polymtl.ca, jarkao2@gmail.com, paulus@samba.org,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090428.064340.193569214.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 28, 2009 at 06:43:40AM -0700, David Miller wrote:
> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 28 Apr 2009 14:40:33 +0200
> 
> > IMHO this locking construct should be considered for 
> > linux/local_lock.h and kernel/local_lock.c. Even if the netfilter 
> > code drops its use soon afterwards ;-)
> 
> If you can show me have to pass a per-cpu variable (the variable,
> not a dereference of it) as an argument to an inline function,
> I'll implement this :-)
> 
> It has to be dereferenced after local_bh_disable() for the
> read side acquisition.

The way I did this in treercu.c was to create an array of references
to the per-CPU data in question.  Not necessarily recommended, but
one way of doing it.  That said, one could argue that we should wait
until we have at least three users before creating a generic primitive.

And I just know that I am going to regret this deeply, but I cannot
resist posting the following URL:

http://en.wikipedia.org/wiki/Wikipedia:Avoid_Parkinson's_Bicycle_Shed_Effect

							Thanx, Paul
