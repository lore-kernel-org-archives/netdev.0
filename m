From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 12515] New: possible circular locking #0:
 (sk_lock-AF_PACKET){--..}, at: [<c1279838>] sock_setsockopt+0x12b/0x4a4
Date: Fri, 30 Jan 2009 14:13:00 -0800 (PST)
Message-ID: <20090130.141300.120552244.davem@davemloft.net>
References: <497FB1C4.3000602@ribosome.natur.cuni.cz>
	<20090130124947.GA6886@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mmokrejs@ribosome.natur.cuni.cz, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	vegard.nossum@gmail.com, a.p.zijlstra@chello.nl, jarkao2@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44436
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754597AbZA3WNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:13:02 -0500
In-Reply-To: <20090130124947.GA6886@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jan 2009 23:49:47 +1100

> packet: Avoid lock_sock in mmap handler
> 
> As the mmap handler gets called under mmap_sem, and we may grab
> mmap_sem elsewhere under the socket lock to access user data, we
> should avoid grabbing the socket lock in the mmap handler.
> 
> Since the only thing we care about in the mmap handler is for
> pg_vec* to be invariant, i.e., to exclude packet_set_ring, we
> can achieve this by simply using sk_receive_queue.lock.
> 
> I resisted the temptation to create a new spin lock because the
> mmap path isn't exactly common.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, applied.

I rewrote the commit message as follows so that it actually
matches what happens in the fix ;-)

--------------------
packet: Avoid lock_sock in mmap handler

As the mmap handler gets called under mmap_sem, and we may grab
mmap_sem elsewhere under the socket lock to access user data, we
should avoid grabbing the socket lock in the mmap handler.

Since the only thing we care about in the mmap handler is for
pg_vec* to be invariant, i.e., to exclude packet_set_ring, we
can achieve this by simply using a new mutex.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
