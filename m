From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 12/30] mm: memory reserve management
Date: Mon, 28 Jul 2008 19:13:46 +0200
Message-ID: <1217265226.18049.24.camel@twins>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>  <1217240224.6331.32.camel@twins>
	 <1217240994.7813.53.camel@penberg-laptop>  <1217241541.6331.42.camel@twins>
	 <1217264374.15724.42.camel@calx>
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
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:20219 "EHLO
	viefep17-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758552AbYG1RN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 13:13:59 -0400
Received: from edge04.upc.biz ([192.168.13.239]) by viefep17-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080728171357.GQTB24448.viefep17-int.chello.at@edge04.upc.biz>
          for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 19:13:57 +0200
In-Reply-To: <1217264374.15724.42.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-07-28 at 11:59 -0500, Matt Mackall wrote:
> On Mon, 2008-07-28 at 12:39 +0200, Peter Zijlstra wrote:
> > Also, you might have noticed, I still need to do everything SLOB. T=
he
> > last time I rewrote all this code I was still hoping Linux would 's=
oon'
> > have a single slab allocator, but evidently we're still going with =
3 for
> > now.. :-/
> >
> > So I guess I can no longer hide behind that and will have to bite t=
he
> > bullet and write the SLOB bits..
>=20
> =EF=BB=BFI haven't seen the rest of this thread, but I presume this i=
s part of
> your OOM-avoidance for network I/O framework?

Yes indeed.

> SLOB can be pretty easily expanded to handle a notion of independent
> allocation arenas as there are only a couple global variables to swit=
ch
> between. =EF=BB=BFkfree will also return allocations to the page list=
 (and
> therefore arena) from whence they came. That may make it pretty simpl=
e
> to create and prepopulate reserve pools.

Right - currently we let all the reserves sit on the free page list. Th=
e
advantage there is that it also helps the anti-frag stuff, due to havin=
g
larger free lists.

