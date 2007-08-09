From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 9 Aug 2007 10:14:19 +0200
Message-ID: <20070809081419.GA9580@osiris.boeblingen.de.ibm.com>
References: <20070808230733.GA17270@shell.boston.redhat.com> <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org> <46BAC2BE.1090106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, ak@suse.de, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:54677 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758869AbXHIIO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 04:14:56 -0400
Content-Disposition: inline
In-Reply-To: <46BAC2BE.1090106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 03:31:10AM -0400, Chris Snook wrote:
>  Linus Torvalds wrote:
> > I'd be *much* happier with "atomic_read()" doing the "volatile" instead.
> > The fact is, volatile on data structures is a bug. It's a wart in the C 
> > language. It shouldn't be used. Volatile accesses in *code* can be ok, and 
> > if we have "atomic_read()" expand to a "*(volatile int *)&(x)->value", then 
> > I'd be ok with that.
> > But marking data structures volatile just makes the compiler screw up 
> > totally, and makes code for initialization sequences etc much worse.
> > 		Linus
> 
>  Fair enough.  Casting to (volatile int *) will give us the behavior people 
>  expect when using atomic_t without needing to use inefficient barriers.
> 
>  While we have the hood up, should we convert all the atomic_t's to 
>  non-volatile and put volatile casts in all the atomic_reads?  I don't know 
>  enough about the various arches to say with confidence that those changes 
>  alone will preserve existing behavior.  We might need some arch-specific 
>  tweaking of the atomic operations.

If you write that patch could you include the atomic64 variants as well,
please? Besides that just post the patch to linux-arch and maintainers
should speak up.
