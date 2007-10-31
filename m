From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 03/33] mm: slub: add knowledge of reserve pages
Date: Wed, 31 Oct 2007 14:08:43 +0100
Message-ID: <1193836123.27652.209.camel@twins>
References: <20071030160401.296770000@chello.nl>
	 <200710312146.03351.nickpiggin@yahoo.com.au>
	 <1193833072.27652.167.camel@twins>
	 <200710312225.07249.nickpiggin@yahoo.com.au>
	 <1193835258.27652.199.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33884 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803AbXJaNIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 09:08:50 -0400
In-Reply-To: <1193835258.27652.199.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-10-31 at 13:54 +0100, Peter Zijlstra wrote:
> On Wed, 2007-10-31 at 22:25 +1100, Nick Piggin wrote:

> > What I'm saying is that the slab allocator slowpath should always
> > just check watermarks against the current task. Instead of this
> > ->reserve stuff.
> 
> So what you say is to allocate a slab every time we take the slow path,
> even when we already have one?

BTW, a task that does not have reserve permissions will already attempt
to allocate a new slab - this is done to probe the current watermarks.
If this succeeds the reserve status is lifted.


