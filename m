From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 5 Nov 2010 11:28:21 -0700
Message-ID: <20101105112821.57f80481.akpm@linux-foundation.org>
References: <1288975980.2882.877.camel@edumazet-laptop>
	<20101105102038.53e36f9e.akpm@linux-foundation.org>
	<1288980046.2882.1054.camel@edumazet-laptop>
	<20101105110828.52f061b3.akpm@linux-foundation.org>
	<1288981224.2882.1105.camel@edumazet-laptop>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38204 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753183Ab0KES24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 14:28:56 -0400
In-Reply-To: <1288981224.2882.1105.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Nov 2010 19:20:24 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 05 novembre 2010 __ 11:08 -0700, Andrew Morton a __crit :
> > On Fri, 05 Nov 2010 19:00:46 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > Le vendredi 05 novembre 2010 __ 10:20 -0700, Andrew Morton a __crit :
> > > 
> > > > It totally makes sense to add include/linu/atomic.h for common things. 
> > > > Perhaps there's already code in arch/*/include/asm/atomic.h which
> > > > should be hoisted up there.  But that can't reliably be done until a
> > > > million files have had their #includes switched :(
> > > > 
> > > 
> > > Maybe including <linux/atomic.h> only from the end of various
> > > 
> > > arch/*/include/asm/atomic.h  ?
> > 
> > heh, I guess that would work.  It breaks the standard way of doing
> > these things (I think?) so let's not go there unless we have a need?
> > 
> > > In this case, I remove the include <asm/atomic.h> from linux/atomic.h
> > 
> > Oh.  Why?  I thought it was better the previous, standard way: thou
> > shalt henceforth include liunx/atomic.h, not asm/atomic.h.  And the
> > presence of linux/atomic.h will in fact trigger the checkpatch warning
> > telling people to use that when they try to use asm/atomic.h.
> 
> Hmm, if we want to move the common stuff from
> arch/*/include/asm/atomic.h to this new file (include/linux/atomic.h),
> then we would have to change hundred of 
> 
> #include <asm/atomic.h> 
> 
> to
> 
> #include <linux/atomic.h> 
> 
> This seems a big task to me ?
> 
> Or just make a whole tree replace ?
> 

But we haven't established that there _is_ duplicated code which needs
that treatment.

Scanning arch/x86/include/asm/atomic.h, perhaps ATOMIC_INIT() is a
candidate.  But I'm not sure that it _should_ be hoisted up - if every
architecture happens to do it the same way then that's just a fluke.


