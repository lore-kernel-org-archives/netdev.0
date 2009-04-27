From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 13:58:48 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904271340400.22156@localhost.localdomain>
References: <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu>
 <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain> <20090427203616.GB3836@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090427203616.GB3836@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 28 Apr 2009, Evgeniy Polyakov wrote:
> 
> Just ot be sure readers will not lose the discssion topic: do you object
> against naming or realizaion?

I said _long_ ago that I thought the patch was fine. 

What I object to is people mis-representing the lock, and apparently 
having a really hard time admitting that having a good grounding in 
networking doesn't necessarily mean that you know everything about 
something as basic as locking.

> If its about the former, does 'dog's breath lock' proposed by Stephen 
> fit?

Is that just an attempt to avoid admitting that they were wrong about lock 
naming? And then trying to trivialize it by calling things by a 
_different_ wrong name, but silly enough that they hope people won't call 
them on it?

Why not just use the correct name? I think it was Mathieu that just 
suggested:

	[PATCH] netfilter: use bh disabling with per-cpu read-write lock

or just call it "netfilter: use per-CPU read-write lock".

Why are people so against calling things by their correct names? Why do 
certain network people seem to force a stupid and incorrect description, 
when they have been told (a) that it's wrong and (b) why it's wrong 
several times?

What's so hard with just doing the TechnicallyRightThing(tm) and 
describing it as such?

And btw - don't get me wrong. There are _other_ ways to do that locking 
too. You don't have to use a rwlock. You can do it with explicit counting, 
the way Eric's original patch did. But it would be wrong to call that one 
"recursive lock" too.

Or you _could_ use a recursive lock, but nobody has actually posted such 
patches. It would work. No question about it. And if it actually _were_ a 
recursive lock, I wouldn't have objected about the description saying it 
is (although I would probably have objected to it being unnecessarily 
complex, when a simpler rwlock or the explicit count thing would be 
sufficient).

But since the current simple patch is using a rwlock, why not just say 
that? Why call it something incorrect ("recursive lock") or nonsensical 
("dog's breath lock").

As I tried to explain with an analogy, networking people would (quite 
correctly) object to me calling a serial line an "ethernet cable". Why is 
it so hard for netfilter people to then see why it's wrong to call a 
rwlock a "recursive lock".

I mean, guys, if you don't want to read up on decades of locking work, 
just google for it. Google for "recursive lock" (_with_ the quotes). At 
least for me, the very first hit gives a reasonable explanation for it, 
and it says:

  "POSIX allows mutexes to be recursive. That means the same thread can 
   lock the same mutex twice and won't deadlock."

and realize that the "same thread" part is very much a keyword, not juat 
a random implementation detail (the first answer to the question is 
better than the question, but even the question at the top really does 
get at the basics).

And please do realize that neither rwlocks nor the counting locks from 
Dumazet's original patch do that. Never did. They simply aren't recursive 
locks.

So just don't call them that. But is "dog's breath" any better? Yes, maybe 
it's less _misleading_, but it sure as hell isn't any more descriptive.

			Linus
