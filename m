From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 01:24:42 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708160118330.16414@enigma.security.iitk.ac.in>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
 <20070815081841.GA16551@osiris.boeblingen.de.ibm.com> <46C30540.2070603@s5r6.in-berlin.de>
 <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in>
 <20070815145207.GA23106@gondor.apana.org.au> <46C3253F.5090707@s5r6.in-berlin.de>
 <20070815162722.GD9645@linux.vnet.ibm.com> <d4406222873856f472b9173a14a19aa2@kernel.crashing.org>
 <20070815185724.GH9645@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, netdev@vger.kernel.org, ak@suse.de,
	cfriesen@nortel.com, Heiko Carstens <heiko.carstens@de.ibm.com>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:49290 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbXHOTms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 15:42:48 -0400
In-Reply-To: <20070815185724.GH9645@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ The Cc: list scares me. Should probably trim it. ]


On Wed, 15 Aug 2007, Paul E. McKenney wrote:

> On Wed, Aug 15, 2007 at 08:31:25PM +0200, Segher Boessenkool wrote:
> > >>How does the compiler know that msleep() has got barrier()s?
> > >
> > >Because msleep_interruptible() is in a separate compilation unit,
> > >the compiler has to assume that it might modify any arbitrary global.
> > 
> > No; compilation units have nothing to do with it, GCC can optimise
> > across compilation unit boundaries just fine, if you tell it to
> > compile more than one compilation unit at once.
> 
> Last I checked, the Linux kernel build system did compile each .c file
> as a separate compilation unit.
> 
> > What you probably mean is that the compiler has to assume any code
> > it cannot currently see can do anything (insofar as allowed by the
> > relevant standards etc.)

I think this was just terminology confusion here again. Isn't "any code
that it cannot currently see" the same as "another compilation unit",
and wouldn't the "compilation unit" itself expand if we ask gcc to
compile more than one unit at once? Or is there some more specific
"definition" for "compilation unit" (in gcc lingo, possibly?)
