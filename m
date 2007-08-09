From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 09 Aug 2007 20:20:46 +0200
Message-ID: <1186683646.9669.20.camel@localhost>
References: <20070808230733.GA17270@shell.boston.redhat.com>
	 <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
	 <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com>
	 <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, Chris Snook <csnook@redhat.com>,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:11609 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbXHISRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 14:17:10 -0400
In-Reply-To: <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-09 at 10:55 -0700, Linus Torvalds wrote:
> > You can use this forget() macro to make the compiler reread a variable:
> > 
> > #define forget(var) asm volatile ("" : "=m"(var))
> 
> No. That will also make the compiler "forget" any previous writes to it, 
> so it changes behaviour.
> 
> You'd have to use "+m".

Yes, though I would use "=m" on the output list and "m" on the input
list. The reason is that I've seen gcc fall on its face with an ICE on
s390 due to "+m". The explanation I've got from our compiler people was
quite esoteric, as far as I remember gcc splits "+m" to an input operand
and an output operand. Now it can happen that the compiler chooses two
different registers to access the same memory location. "+m" requires
that the two memory references are identical which causes the ICE if
they are not. I do not know if the current compilers still do this. Has
anyone else seen this happen ?

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


