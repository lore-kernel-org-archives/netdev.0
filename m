From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sun, 12 Aug 2007 21:13:20 +0200
Message-ID: <bd062b9b86e3e26ff7282bfb3b6106e4@kernel.crashing.org>
References: <20070808230733.GA17270@shell.boston.redhat.com> <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org> <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com> <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org> <1186683646.9669.20.camel@localhost> <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org> <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org> <1186912098.3852.11.camel@localhost> <74868f39491f8691afc5540f72679129@kernel.crashing.org> <alpine.LFD.0.999.0708121107490.30176@woody.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, netdev@vger.kernel.org,
	horms@verge.net.au, akpm@linux-foundation.org,
	schwidefsky@de.ibm.com, Chuck Ebbert <cebbert@redhat.com>,
	davem@davemloft.net, zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35515 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933141AbXHLTO1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 15:14:27 -0400
In-Reply-To: <alpine.LFD.0.999.0708121107490.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Yeah.  Compiler errors are more annoying though I dare say ;-)
>
> Actually, compile-time errors are fine,

Yes, they don't cause data corruption or anything like that,
but I still don't think the 390 people want to ship a kernel
that doesn't build -- and it seems they still need to support
GCC versions before 4.0.  Up until the day they can finally
drop 3.x, they'll have to...

> and easy to work around.

...use the simple workaround, annoying as it may be, at least
it works.  That's all I'm saying.

> *Much*
> more annoying is when gcc actively generates subtly bad code.

Quite so.

> We've had
> use-after-free issues due to incorrect gcc liveness calculations etc, 
> and
> inline asm has beeen one of the more common causes - exactly because 
> the
> kernel is one of the few users (along with glibc) that uses it at all.

The good news is that things are getting better since more and
more of the RTL transformations are ripped out.

> Now *those* are hard to find - the code works most of the time, but the
> compiler has inserted a really subtle race condition into the code
> (deallocated a local stack entry before last use). We had that with our
> semaphore code at some point.

Yeah, magnifying glass + lots of time kind of bug.  Lovely :-/


Segher

