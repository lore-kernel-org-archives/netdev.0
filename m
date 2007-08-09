From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 9 Aug 2007 21:25:43 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708092123270.22584@anakin>
References: <20070809132442.GA13042@shell.boston.redhat.com>
 <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com>
 <20070809150445.GB8424@linux.vnet.ibm.com> <46BB31A6.4080507@redhat.com>
 <3bfabd7472d6f019aa1880b14013f7a1@kernel.crashing.org> <46BB3ECF.2070100@redhat.com>
 <1abc2c621d6b62b3ac9f489d4d18806a@kernel.crashing.org> <46BB656D.6090408@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	wjiang@resilience.com, cfriesen@nortel.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	horms@verge.net.au, akpm@linux-foundation.org,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	torvalds@linux-foundation.org, zlynx@acm.org,
	rpjday@mindspring.com, schwidefsky@de.ibm.com, davem@davemloft.net
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761653AbXHIT0m@vger.kernel.org>
In-Reply-To: <46BB656D.6090408@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Aug 2007, Chris Snook wrote:
> Segher Boessenkool wrote:
> > > > The only safe way to get atomic accesses is to write
> > > > assembler code.  Are there any downsides to that?  I don't
> > > > see any.
> > > 
> > > The assumption that aligned word reads and writes are atomic, and that
> > > words are aligned unless explicitly packed otherwise, is endemic in the
> > > kernel.  No sane compiler violates this assumption.  It's true that we're
> > > not portable to insane compilers after this patch, but we never were in
> > > the first place.
> > 
> > You didn't answer my question: are there any downsides to using
> > explicit coded-in-assembler accesses for atomic accesses?  You
> > can handwave all you want that it should "just work" with
> > volatile accesses, but volatility != atomicity, volatile in C
> > is really badly defined, GCC never officially gave stronger
> > guarantees, and we have a bugzilla full of PRs to show what a
> > minefield it is.
> > 
> > So, why not use the well-defined alternative?
> 
> Because we don't need to, and it hurts performance.

It hurts performance by implementing 32-bit atomic reads in assembler?

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
