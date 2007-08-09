From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 24/24] document volatile atomic_read() behavior
Date: Fri, 10 Aug 2007 00:34:58 +0200
Message-ID: <072b6e3f812a116d3972cef8e76c57f1@kernel.crashing.org>
References: <20070809142430.GA19817@shell.boston.redhat.com> <8f6bb8a9e4f2819a161d732bdb6c70c0@kernel.crashing.org> <46BB403D.10202@redhat.com> <0a08872e608cf5f7a3d9c0fc746a1051@kernel.crashing.org> <46BB7371.7060008@redhat.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, netdev@vger.kernel.org,
	horms@verge.net.au, akpm@linux-foundation.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	schwidefsky@de.ibm.com, davem@davemloft.net, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756557AbXHIWg0@vger.kernel.org>
In-Reply-To: <46BB7371.7060008@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Anyway, what's the supposed advantage of *(volatile *) vs. using
>> a real volatile object?  That you can access that same object in
>> a non-volatile way?
>
> You'll have to take that up with Linus and the minds behind Volatile 
> Considered Harmful, but the crux of it is that volatile objects are 
> prone to compiler bugs too, and if we have to track down a compiler 
> bug, it's a lot easier when we know exactly where the load is supposed 
> to be because we deliberately put it there, rather than letting the 
> compiler re-order everything that lacks a strict data dependency and 
> trying to figure out where in a thousand lines of assembler the 
> compiler should have put the load for the volatile object.

So, why not do the access explicitly via an inline asm?  It
generates the same code, it's obviously correct, and it's
even *actually* correct.  Plus, you get good compiler
support (and compiler people support).

> If we're going to assume that the compiler has bugs we'll never be 
> able to find, we all need to find new careers.

If we cannot find the bug in finite time, we cannot observe
the bug in finite time either, so either way that's fine :-)

> If we're going to assume that it has bugs we *can* find, then let's 
> use code that makes it easier to do that.

And I'm saying this is a step in the wrong direction for that.

> I initially proposed a patch that made all the objects volatile, on 
> the grounds that this was a special case where there wasn't much room 
> to have a misunderstanding that resulted in anything worse than wasted 
> loads.  Linus objected, and now that I've seen all the responses to 
> the new patchset, I understand exactly why.  If our compilers really 
> suck as much as everyone says they do, it'll be much easier to detect 
> that with volatile casts than with volatile declarations.

Except that accesses via volatile pointer casts open up a whole
new can of worms.


Segher
