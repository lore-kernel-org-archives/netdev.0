From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 09:27:22 -0700
Message-ID: <20070815162722.GD9645@linux.vnet.ibm.com>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <20070815081841.GA16551@osiris.boeblingen.de.ibm.com> <46C30540.2070603@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in> <20070815145207.GA23106@gondor.apana.org.au> <46C3253F.5090707@s5r6.in-berlin.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Satyam Sharma <satyam@infradead.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Chris Snook <csnook@redhat.com>, clameter@sgi.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, davem@davemloft.net, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36754 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761679AbXHOQ10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 12:27:26 -0400
Content-Disposition: inline
In-Reply-To: <46C3253F.5090707@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 06:09:35PM +0200, Stefan Richter wrote:
> Herbert Xu wrote:
> > On Wed, Aug 15, 2007 at 08:05:38PM +0530, Satyam Sharma wrote:
> >>> I don't know if this here is affected:
> 
> [...something like]
> 	b = atomic_read(a);
> 	for (i = 0; i < 4; i++) {
> 		msleep_interruptible(63);
> 		c = atomic_read(a);
> 		if (c != b) {
> 			b = c;
> 			i = 0;
> 		}
> 	}
> 
> > Nope, we're calling schedule which is a rather heavy-weight
> > barrier.
> 
> How does the compiler know that msleep() has got barrier()s?

Because msleep_interruptible() is in a separate compilation unit,
the compiler has to assume that it might modify any arbitrary global.
In many cases, the compiler also has to assume that msleep_interruptible()
might call back into a function in the current compilation unit, thus
possibly modifying global static variables.

						Thanx, Paul
