From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sun, 12 Aug 2007 11:11:25 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708121107490.30176@woody.linux-foundation.org>
References: <20070808230733.GA17270@shell.boston.redhat.com>
 <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
 <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com>
 <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org>
 <1186683646.9669.20.camel@localhost> <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org>
 <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org>
 <1186912098.3852.11.camel@localhost>
 <74868f39491f8691afc5540f72679129@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: schwidefsky@de.ibm.com, wjiang@resilience.com,
	wensong@linux-vs.org, heiko.carstens@de.ibm.com,
	linux-kernel@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	netdev@vger.kernel.org, horms@verge.net.au,
	akpm@linux-foundation.org, Chuck Ebbert <cebbert@redhat.com>,
	davem@davemloft.net, zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38942 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752603AbXHLSMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2007 14:12:21 -0400
In-Reply-To: <74868f39491f8691afc5540f72679129@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 12 Aug 2007, Segher Boessenkool wrote:
> 
> Yeah.  Compiler errors are more annoying though I dare say ;-)

Actually, compile-time errors are fine, and easy to work around. *Much* 
more annoying is when gcc actively generates subtly bad code. We've had 
use-after-free issues due to incorrect gcc liveness calculations etc, and 
inline asm has beeen one of the more common causes - exactly because the 
kernel is one of the few users (along with glibc) that uses it at all.

Now *those* are hard to find - the code works most of the time, but the 
compiler has inserted a really subtle race condition into the code 
(deallocated a local stack entry before last use). We had that with our 
semaphore code at some point.

		Linus
