From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 02:44:53 +0100
Message-ID: <1319766293.6759.17.camel@deadeye>
References: <1319764761.23112.14.camel@edumazet-laptop>
	 <20111028012521.GF25795@one.firstfloor.org>
	 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-10-27 at 18:34 -0700, Linus Torvalds wrote:
> On Thu, Oct 27, 2011 at 6:25 PM, Andi Kleen <andi@firstfloor.org> wrote:
> >
> > Seems reasonable too. In fact we usually should have memory barriers
> > for this anyways which obsolete the volatile.
> 
> No we shouldn't. Memory barriers are insanely expensive, and pointless
> for atomics - that aren't ordered anyway.
> 
> You may mean compiler barriers.
> 
> That said, removing the volatile entirely might be a good idea, and
> never mind any barriers at all. The ordering for atomics really isn't
> well enough specified that we should care. So I wouldn't object to a
> patch that just removes the volatile entirely, but it would have to be
> accompanied with quite a bit of testing, in case some odd case ends up
> depending on it. But nothing *should* be looping on those things
> anyway.

Whether or not it needs to provide any ordering guarantee, atomic_read()
must never read more than once, and I think that requires the volatile
qualification.  It might be clearer to use the ACCESS_ONCE macro,
however.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
