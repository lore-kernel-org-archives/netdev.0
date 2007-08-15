From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
	architectures
Date: Wed, 15 Aug 2007 10:18:41 +0200
Message-ID: <20070815081841.GA16551@osiris.boeblingen.de.ibm.com>
References: <46C2350A.1010807@redhat.com> <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Snook <csnook@redhat.com>, satyam@infradead.org,
	clameter@sgi.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:40813 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbXHOISr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 04:18:47 -0400
Content-Disposition: inline
In-Reply-To: <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 02:49:03PM +0800, Herbert Xu wrote:
> Chris Snook <csnook@redhat.com> wrote:
> > 
> > Because atomic operations are generally used for synchronization, which requires 
> > volatile behavior.  Most such codepaths currently use an inefficient barrier(). 
> >  Some forget to and we get bugs, because people assume that atomic_read() 
> > actually reads something, and atomic_write() actually writes something.  Worse, 
> > these are architecture-specific, even compiler version-specific bugs that are 
> > often difficult to track down.
> 
> I'm yet to see a single example from the current tree where
> this patch series is the correct solution.  So far the only
> example has been a buggy piece of code which has since been
> fixed with a cpu_relax.

Btw.: we still have

include/asm-i386/mach-es7000/mach_wakecpu.h:  while (!atomic_read(deassert));
include/asm-i386/mach-default/mach_wakecpu.h: while (!atomic_read(deassert));

Looks like they need to be fixed as well.
