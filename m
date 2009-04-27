From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 20:54:23 +0200
Message-ID: <20090427185423.GC23862@elte.hu>
References: <20090423210938.1501507b@nehalam> <49F146FF.5050200@cosmosbay.com> <20090424091839.6e13ebec@nehalam> <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090427113010.5e3f1700@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stephen Hemminger <shemminger@vyatta.com> wrote:

> > non of the linux kernel locking primitives have this -- with the 
> > possible exception of the cpu-hotplug lock.
> > 
> > What rwlock_t has, is reader bias to the point where you can 
> > utterly starve writers, with the side effect that you can obtain 
> > multiple read ownerships without causing a deadlock.
> 
> But what happens when this side effect disappears?

Then well written code works, badly written code breaks.

> > [...]
> >
> > This is all common and well understood terminology, not 
> > something Linus invented just to harras you with.
> 
> In Documentation/ ?  online ?  Where is the definition? The only 
> reference I se is indirectly in DocBook/kernel-locking.tmpl.

Sure, see:

    http://tinyurl.com/c6fakc

> > Generally speaking we do not condone recursive locking 
> > strategies -- and afaik reiserfs (as per the BKL) and the 
> > network code (as per abusing rwlock_t unfairness) are the only 
> > offenders.
> > 
> > Like Linus stated, recursive locking is generally poor taste and 
> > indicates you basically gave up on trying to find a proper 
> > locking scheme. We should very much work towards getting rid of 
> > these abberations instead of adding new ones.
> 
> The people complaining about naming never seem to be the ones 
> providing workable suggestions or patches.

The thing is, while you now have named your locking primitive 
correctly, you are still abusing it by using it recursively.

So it's not 'just about naming'. You should not use read-locks as 
recursive locks. It's poor code.

	Ingo
