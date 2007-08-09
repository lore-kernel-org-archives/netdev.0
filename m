From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch] ipvs: force read of atomic_t in while loop
Date: Thu, 09 Aug 2007 14:49:25 +0200
Message-ID: <1186663765.9669.6.camel@localhost>
References: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com>
	 <46BA30DC.20207@redhat.com> <20070809001533.GA17798@one.firstfloor.org>
	 <200708091435.18595.mb@bu3sch.de>  <46BB0B4B.4070300@redhat.com>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Andi Kleen <andi@firstfloor.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	wensong@linux-vs.org, horms@verge.net.au, torvalds@osdl.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:65479 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S939409AbXHIMpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 08:45:50 -0400
In-Reply-To: <46BB0B4B.4070300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-09 at 08:40 -0400, Chris Snook wrote:
> > #define reload_var(x) __asm__ __volatile__ (whatever, x)
> > 
> > I don't know inline assembly that much, but isn't it possible
> > with that to kind of "fake-touch" the variable, so the compiler
> > must reload it (and only it) to make sure it's up to date?
> 
> We can do it in C, like this:
> 
> -#define atomic_read(v) ((v)->counter)
> +#define atomic_read(v) (*(volatile int *)&(v)->counter)
> 
> By casting it volatile at the precise piece of code where we want to
> guarantee a read from memory, there's little risk of the compiler
> getting creative in its interpretation of the code.

To answer the inline assembler question:

asm volatile ("" : "=m" (counter)) : "m" (counter) )

will force the compiler to reload the value from memory. But the cast to
(volatile int *) is even better.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


