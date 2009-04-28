From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 13:35:40 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904281330390.13862@qirst.com>
References: <49F6A8FD.3010804@cosmosbay.com> <20090428.045342.206106171.davem@davemloft.net> <20090428124033.GA1655@elte.hu> <20090428.064340.193569214.davem@davemloft.net> <20090428154213.GA10833@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	dada1@cosmosbay.com, torvalds@linux-foundation.org,
	shemminger@vyatta.com, zbr@ioremap.net, peterz@infradead.org,
	mathieu.desnoyers@polymtl.ca, jarkao2@gmail.com, paulus@samba.org,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090428154213.GA10833@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Apr 2009, Paul E. McKenney wrote:

> > If you can show me have to pass a per-cpu variable (the variable,
> > not a dereference of it) as an argument to an inline function,
> > I'll implement this :-)
> >
> > It has to be dereferenced after local_bh_disable() for the
> > read side acquisition.
>
> The way I did this in treercu.c was to create an array of references
> to the per-CPU data in question.  Not necessarily recommended, but
> one way of doing it.  That said, one could argue that we should wait
> until we have at least three users before creating a generic primitive.

The new percpu allocator allows you to create a per cpu pointer and pass
it to functions.

per_cpu_ptr(pointer,cpu) is used to select an instance.
