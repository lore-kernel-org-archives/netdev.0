From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 5 Nov 2010 11:08:28 -0700
Message-ID: <20101105110828.52f061b3.akpm@linux-foundation.org>
References: <1288975980.2882.877.camel@edumazet-laptop>
	<20101105102038.53e36f9e.akpm@linux-foundation.org>
	<1288980046.2882.1054.camel@edumazet-laptop>
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
In-Reply-To: <1288980046.2882.1054.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 Nov 2010 19:00:46 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 05 novembre 2010 __ 10:20 -0700, Andrew Morton a __crit :
> 
> > It totally makes sense to add include/linu/atomic.h for common things. 
> > Perhaps there's already code in arch/*/include/asm/atomic.h which
> > should be hoisted up there.  But that can't reliably be done until a
> > million files have had their #includes switched :(
> > 
> 
> Maybe including <linux/atomic.h> only from the end of various
> 
> arch/*/include/asm/atomic.h  ?

heh, I guess that would work.  It breaks the standard way of doing
these things (I think?) so let's not go there unless we have a need?

> In this case, I remove the include <asm/atomic.h> from linux/atomic.h

Oh.  Why?  I thought it was better the previous, standard way: thou
shalt henceforth include liunx/atomic.h, not asm/atomic.h.  And the
presence of linux/atomic.h will in fact trigger the checkpatch warning
telling people to use that when they try to use asm/atomic.h.

> > > +static inline int atomic_inc_not_zero_hint(atomic_t *v, int hint)
> > > +{
> > > +	int val, c = hint;
> > > +
> > > + 	do {
> > > +		val = atomic_cmpxchg(v, c, c + 1);
> > > +		if (val == c)
> > > +			return 1;
> > > +		c = val;
> > > +	} while (c);
> > > +
> > > +	return 0;
> > > +}
> > 
> > Should/could this have implemented a more general
> > atomic_add_not_zero_hint() and made atomic_inc_not_zero_hint() a
> > wrapper around that?
> 
> Well, I see no practical use for this, but yes, this could be done.
> 
> As atomic_add_not_zero() doesnt exist, I am not sure we need an
> atomic_add_not_zero_hint() yet ?

hm, OK.  I was just checking ;)
