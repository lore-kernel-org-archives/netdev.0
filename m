From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling to mitigate SYN floods
Date: Tue, 29 May 2012 12:37:07 -0700
Message-ID: <m2bol6lqxo.fsf@firstfloor.org>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	<20120528115226.12068.31850.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22382 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754581Ab2E2ThM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 15:37:12 -0400
In-Reply-To: <20120528115226.12068.31850.stgit@localhost.localdomain> (Jesper
	Dangaard Brouer's message of "Mon, 28 May 2012 13:52:26 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <jbrouer@redhat.com> writes:

> TCP SYN handling is on the slow path via tcp_v4_rcv(), and is
> performed while holding spinlock bh_lock_sock().
>
> Real-life and testlab experiments show, that the kernel choks
> when reaching 130Kpps SYN floods (powerful Nehalem 16 cores).
> Measuring with perf reveals, that its caused by
> bh_lock_sock_nested() call in tcp_v4_rcv().
>
> With this patch, the machine can handle 750Kpps (max of the SYN
> flood generator) with cycles to spare, CPU load on the big machine
> dropped to 1%, from 100%.
>
> Notice we only handle syn cookie early on, normal SYN packets
> are still processed under the bh_lock_sock().

So basically handling syncookie lockless? 

Makes sense. Syncookies is a bit obsolete these days of course, due
to the lack of options. But may be still useful for this.

Obviously you'll need to clean up the patch and support IPv6,
but the basic idea looks good to me.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
