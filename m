From: Jerry Jiang <wjiang@resilience.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 9 Aug 2007 12:59:20 +0800
Message-ID: <20070809125920.37eb6e6d.wjiang@resilience.com>
References: <20070808230733.GA17270@shell.boston.redhat.com>
	<alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, akpm@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	cfriesen@nortel.com, zlynx@acm.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S938462AbXHIFFX@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Aug 2007 21:18:25 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Wed, 8 Aug 2007, Chris Snook wrote:
> > 
> > Some architectures currently do not declare the contents of an atomic_t to be
> > volatile.  This causes confusion since atomic_read() might not actually read
> > anything if an optimizing compiler re-uses a value stored in a register, which
> > can break code that loops until something external changes the value of an
> > atomic_t.
> 
> I'd be *much* happier with "atomic_read()" doing the "volatile" instead.
> 
> The fact is, volatile on data structures is a bug. It's a wart in the C 
> language. It shouldn't be used. 

Why? It's a wart! Is it due to unclear C standard on volatile related point?

Why the *volatile-accesses-in-code* is acceptable, does C standard make it clear?

-- Jerry

> 
> Volatile accesses in *code* can be ok, and if we have "atomic_read()" 
> expand to a "*(volatile int *)&(x)->value", then I'd be ok with that.
> 
> But marking data structures volatile just makes the compiler screw up 
> totally, and makes code for initialization sequences etc much worse.
> 
> 		Linus
