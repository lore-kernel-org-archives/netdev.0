From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 5 Nov 2010 12:39:27 -0700
Message-ID: <20101105123927.5779e464.akpm@linux-foundation.org>
References: <1288975980.2882.877.camel@edumazet-laptop>
	<20101105102038.53e36f9e.akpm@linux-foundation.org>
	<1288980046.2882.1054.camel@edumazet-laptop>
	<20101105110828.52f061b3.akpm@linux-foundation.org>
	<1288981224.2882.1105.camel@edumazet-laptop>
	<20101105112821.57f80481.akpm@linux-foundation.org>
	<1288984844.2665.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@kernel.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288984844.2665.52.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 Nov 2010 20:20:44 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 05 novembre 2010 __ 11:28 -0700, Andrew Morton a __crit :
> > But we haven't established that there _is_ duplicated code which needs
> > that treatment.
> > 
> > Scanning arch/x86/include/asm/atomic.h, perhaps ATOMIC_INIT() is a
> > candidate.  But I'm not sure that it _should_ be hoisted up - if every
> > architecture happens to do it the same way then that's just a fluke.
> > 
> > 
> 
> Not sure I understand you. I was trying to avoid recursive includes, but
> that should be protected anyway. I see a lot of code that could be
> factorized in this new header (atomic_inc_not_zero() for example)

Ah.  I wasn't able to see much duplicated code at all, so I wasn't sure
that we needed to bother about this issue.

yup, atomic_inc_not_zero() looks like a candidate.

> [PATCH v3] atomic: add atomic_inc_not_zero_hint()

Let's go with this for now ;)

I'll assume that you intend to make use of this function soon, and it
looks safe enough to sneak it into 2.6.37-rc2, IMO.  If Linus shouts at
me then we could merge it into 2.6.38-rc1 via net-next, but I think
straight-to-mainline is best.
