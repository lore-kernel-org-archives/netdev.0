From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 19:22:26 -0700
Message-ID: <20070816022226.GA14613@linux.vnet.ibm.com>
References: <46C30540.2070603@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in> <20070815145207.GA23106@gondor.apana.org.au> <46C3253F.5090707@s5r6.in-berlin.de> <20070815162722.GD9645@linux.vnet.ibm.com> <d4406222873856f472b9173a14a19aa2@kernel.crashing.org> <20070815185724.GH9645@linux.vnet.ibm.com> <2c907d70a2267b887de346891758983d@kernel.crashing.org> <20070815224433.GQ9645@linux.vnet.ibm.com> <f24994ecd2ecfcda6e01b289a25c1e47@kernel.crashing.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Satyam Sharma <satyam@infradead.org>,
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
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:39417 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757167AbXHPCWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 22:22:31 -0400
Content-Disposition: inline
In-Reply-To: <f24994ecd2ecfcda6e01b289a25c1e47@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 03:23:28AM +0200, Segher Boessenkool wrote:
> >>>>No; compilation units have nothing to do with it, GCC can optimise
> >>>>across compilation unit boundaries just fine, if you tell it to
> >>>>compile more than one compilation unit at once.
> >>>
> >>>Last I checked, the Linux kernel build system did compile each .c 
> >>>file
> >>>as a separate compilation unit.
> >>
> >>I have some patches to use -combine -fwhole-program for Linux.
> >>Highly experimental, you need a patched bleeding edge toolchain.
> >>If there's interest I'll clean it up and put it online.
> >>
> >>David Woodhouse had some similar patches about a year ago.
> >
> >Sounds exciting...  ;-)
> 
> Yeah, the breakage is *quite* spectacular :-)

I bet!!!  ;-)

> >>>>>In many cases, the compiler also has to assume that
> >>>>>msleep_interruptible()
> >>>>>might call back into a function in the current compilation unit, 
> >>>>>thus
> >>>>>possibly modifying global static variables.
> >>>>
> >>>>It most often is smart enough to see what compilation-unit-local
> >>>>variables might be modified that way, though :-)
> >>>
> >>>Yep.  For example, if it knows the current value of a given such 
> >>>local
> >>>variable, and if all code paths that would change some other variable
> >>>cannot be reached given that current value of the first variable.
> >>
> >>Or the most common thing: if neither the address of the translation-
> >>unit local variable nor the address of any function writing to that
> >>variable can "escape" from that translation unit, nothing outside
> >>the translation unit can write to the variable.
> >
> >But there is usually at least one externally callable function in
> >a .c file.
> 
> Of course, but often none of those will (indirectly) write a certain
> static variable.

But there has to be some path to the static functions, assuming that
they are not dead code.  Yes, there can be cases where the compiler
knows enough about the state of the variables to rule out some of code
paths to them, but I have no idea how often this happens in kernel
code.

						Thanx, Paul
