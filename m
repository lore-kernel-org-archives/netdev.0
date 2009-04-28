From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 09:52:19 -0400
Message-ID: <20090428135219.GA28513@Krystal>
References: <49F6A8FD.3010804@cosmosbay.com> <20090428.045342.206106171.davem@davemloft.net> <20090428124033.GA1655@elte.hu> <20090428.064340.193569214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, dada1@cosmosbay.com, torvalds@linux-foundation.org,
	shemminger@vyatta.com, zbr@ioremap.net, peterz@infradead.org,
	jarkao2@gmail.com, paulus@samba.org, paulmck@linux.vnet.ibm.com,
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

* David Miller (davem@davemloft.net) wrote:
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

The local_bh_disable() could be outside of the locking construct. This
would make it easier to adapt it to various users (irq disable, bh
disable, preempt disable) depending on the contexts from which they much
be protected.

And if it still does not work for some reason, using a #define is
discouraged, but could work.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
