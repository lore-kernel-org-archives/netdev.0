From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 03/33] mm: slub: add knowledge of reserve pages
Date: Wed, 31 Oct 2007 14:37:28 +1100
Message-ID: <200710311437.28630.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl> <20071030160910.813944000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.mail.mud.yahoo.com ([209.191.85.217]:28895 "HELO
	smtp107.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752805AbXJaEoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 00:44:08 -0400
In-Reply-To: <20071030160910.813944000@chello.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> contexts that are entitled to it.
>
> Care is taken to only touch the SLUB slow path.
>
> This is done to ensure reserve pages don't leak out and get consumed.

I think this is generally a good idea (to prevent slab allocators
from stealing reserve). However I naively think the implementation
is a bit overengineered and thus has a few holes.

Humour me, what was the problem with failing the slab allocation
(actually, not fail but just call into the page allocator to do
correct waiting  / reclaim) in the slowpath if the process fails the
watermark checks?
