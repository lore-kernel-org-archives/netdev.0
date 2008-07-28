From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 12/30] mm: memory reserve management
Date: Mon, 28 Jul 2008 11:59:34 -0500
Message-ID: <1217264374.15724.42.camel@calx>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>  <1217240224.6331.32.camel@twins>
	 <1217240994.7813.53.camel@penberg-laptop>  <1217241541.6331.42.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Neil Brown <neilb@suse.de>, cl@linux-foundation.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:51143 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757040AbYG1RD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 13:03:26 -0400
In-Reply-To: <1217241541.6331.42.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-07-28 at 12:39 +0200, Peter Zijlstra wrote:
> Also, you might have noticed, I still need to do everything SLOB. The
> last time I rewrote all this code I was still hoping Linux would 'soo=
n'
> have a single slab allocator, but evidently we're still going with 3 =
for
> now.. :-/
>
> So I guess I can no longer hide behind that and will have to bite the
> bullet and write the SLOB bits..

=EF=BB=BFI haven't seen the rest of this thread, but I presume this is =
part of
your OOM-avoidance for network I/O framework?

SLOB can be pretty easily expanded to handle a notion of independent
allocation arenas as there are only a couple global variables to switch
between. =EF=BB=BFkfree will also return allocations to the page list (=
and
therefore arena) from whence they came. That may make it pretty simple
to create and prepopulate reserve pools.

--=20
Mathematics is the supreme nostalgia of our time.

