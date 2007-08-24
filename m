From: "Kenn Humborg" <kenn@bluetree.ie>
Subject: RE: [PATCH] i386: Fix a couple busy loops in mach_wakecpu.h:wait_for_init_deassert()
Date: Fri, 24 Aug 2007 13:12:54 +0100
Message-ID: <NBBBIGEGHIGMPCNKHCECAEPEELAA.kenn@bluetree.ie>
References: <200708241259.33659.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Heiko Carstens" <heiko.carstens@de.ibm.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Chris Snook" <csnook@redhat.com>, <clameter@sgi.com>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<linux-arch@vger.kernel.org>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	<netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>, <ak@suse.de>,
	<davem@davemloft.net>, <schwidefsky@de.ibm.com>,
	<wensong@linux-vs.org>, <horms@verge.net.au>,
	<wjiang@resilience.com>, <cfriesen@nortel.com>, <zlynx@acm.org>,
	<rpjday@mindspring.com>, <jesper.juhl@gmail.com>,
	<segher@kernel.crashing.org>
To: "Denys Vlasenko" <vda.linux@googlemail.com>,
	"Satyam Sharma" <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerberus.bluetree.ie ([87.198.132.99]:48977 "EHLO
	cerberus.bluetree.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757396AbXHXMYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 08:24:10 -0400
In-Reply-To: <200708241259.33659.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Thursday 16 August 2007 01:39, Satyam Sharma wrote:
> >
> >  static inline void wait_for_init_deassert(atomic_t *deassert)
> >  {
> > -	while (!atomic_read(deassert));
> > +	while (!atomic_read(deassert))
> > +		cpu_relax();
> >  	return;
> >  }
> 
> For less-than-briliant people like me, it's totally non-obvious that
> cpu_relax() is needed for correctness here, not just to make P4 happy.
> 
> IOW: "atomic_read" name quite unambiguously means "I will read
> this variable from main memory". Which is not true and creates
> potential for confusion and bugs.

To me, "atomic_read" means a read which is synchronized with other 
changes to the variable (using the atomic_XXX functions) in such 
a way that I will always only see the "before" or "after"
state of the variable - never an intermediate state while a 
modification is happening.  It doesn't imply that I have to 
see the "after" state immediately after another thread modifies
it.

Perhaps the Linux atomic_XXX functions work like that, or used
to work like that, but it's counter-intuitive to me that "atomic"
should imply a memory read.

Later,
Kenn

