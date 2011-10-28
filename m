From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Thu, 27 Oct 2011 18:34:48 -0700
Message-ID: <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
References: <1319764761.23112.14.camel@edumazet-laptop> <20111028012521.GF25795@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111028012521.GF25795@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2011 at 6:25 PM, Andi Kleen <andi@firstfloor.org> wrote:
>
> Seems reasonable too. In fact we usually should have memory barriers
> for this anyways which obsolete the volatile.

No we shouldn't. Memory barriers are insanely expensive, and pointless
for atomics - that aren't ordered anyway.

You may mean compiler barriers.

That said, removing the volatile entirely might be a good idea, and
never mind any barriers at all. The ordering for atomics really isn't
well enough specified that we should care. So I wouldn't object to a
patch that just removes the volatile entirely, but it would have to be
accompanied with quite a bit of testing, in case some odd case ends up
depending on it. But nothing *should* be looping on those things
anyway.

                       Linus
