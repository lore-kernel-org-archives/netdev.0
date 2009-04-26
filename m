From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH] netfilter: use per-CPU recursive lock {XV}
Date: Sun, 26 Apr 2009 18:32:11 -0400
Message-ID: <20090426223211.GB825@Krystal>
References: <20090421143927.52d7d89d@nehalam> <alpine.LFD.2.00.0904220821240.3101@localhost.localdomain> <20090423210938.1501507b@nehalam> <49F146FF.5050200@cosmosbay.com> <20090424091839.6e13ebec@nehalam> <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, Thomas Gleixner <tglx@linutronix.de>,
	Steven Rostedt <rostedt@goodmis.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754646AbZDZWhu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090426145746.1184aeba@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger (shemminger@vyatta.com) wrote:
> On Sun, 26 Apr 2009 14:56:46 -0400
> Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> 
> > * Eric Dumazet (dada1@cosmosbay.com) wrote:
> > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > 
> > > > Epilogue due to master Jarek. Lockdep carest not about the locking
> > > > doth bestowed. Therefore no keys are needed.
> > > > 
> > > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > > 
> > > So far, so good, should be ready for inclusion now, nobody complained :)
> > > 
> > > I include the final patch, merge of your last two patches.
> > > 
> > > David, could you please review it once again and apply it if it's OK ?
> > 
> > > Thanks to all for your help and patience
> > > 
> > > [PATCH] netfilter: use per-CPU recursive lock {XV}
> > 
> > Hi Eric, 
> > 
> > Suitable name would probably be :
> > 

Hi Stephen,

[I see that you have cutted my name proposal from the original email,
which might make it difficult for others to follow. I will assume you
did it by mistake.]

(re-added)
[PATCH] netfilter: use bh disabling with per-cpu read-write lock

> 
> But Linus is trying to delude himself.
> 
> This usage is recursive even if he doesn't like the terminology.
> The same CPU has to be able to reacquire the read lock without deadlocking.
> If reader/writer locks were implemented in a pure writer gets priority
> method, then this code would break!  So yes read locks can be used recursively
> now in Linux, but if the were implemented differently then this code
> would break.  For example, the -rt kernel turns all read/write locks into
> mutexs, so the -rt kernel developers will have to address this.

Reading Documentation/spinlocks.txt, which states the lock usage
guidelines :

"Note that you can be clever with read-write locks and interrupts. For
example, if you know that the interrupt only ever gets a read-lock, then
you can use a non-irq version of read locks everywhere - because they
don't block on each other (and thus there is no dead-lock wrt interrupts.
But when you do the write-lock, you have to use the irq-safe version."

So it's assumed in the kernel-wide read lock usage that nested read
locks are OK. I'm adding Thomas and Steven in CC, but I'm quite sure
they must have dealt with nested read-lock transformation into mutexes
by detecting nesting in some way in -rt. But I'll let them confirm this.

So I don't see why you are dreaming about a different semantic than the
one of the primitives you are using. I guess I'll leave the semantics to
you. I just find it astonishing that you persist saying that everbody is
wrong on a topic like semantic, which is in the end a mean to
communicate ideas clearly within the overall community you disagree
with.

Good luck !

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
