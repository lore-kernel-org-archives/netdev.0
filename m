From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Wed, 11 Aug 2010 11:37:36 -0400
Message-ID: <20100811153736.GA31577@tuxdriver.com>
References: <1281471924-2237-1-git-send-email-linville@tuxdriver.com>
 <20100810204358.GA1076@gondor.apana.org.au>
 <20100810211932.GG2379@linux.vnet.ibm.com>
 <20100810.163117.241919476.davem@davemloft.net>
 <20100811110330.GA6440@gondor.apana.org.au>
 <20100811112706.GA6772@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39656 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854Ab0HKPoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 11:44:44 -0400
Content-Disposition: inline
In-Reply-To: <20100811112706.GA6772@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 07:27:06AM -0400, Herbert Xu wrote:
> On Wed, Aug 11, 2010 at 07:03:30AM -0400, Herbert Xu wrote:
> >
> > To use rcu_read_lock safely we'd also need to add do synchronize_rcu
> > in addition of synchronize_rcu_bh, right Paul?
> > 
> > Of course as we were doing this unsafely prior to my patch anyway
> > I'm also fine with just reverting it.
> 
> Actually, we could just disable IRQs for stable.  How about this
> patch (untested)?
> 
> netpoll: Disable IRQ around RCU dereference in netpoll_rx
> 
> We cannot use rcu_dereference_bh safely in netpoll_rx as we may
> be called with IRQs disabled.  We could however simply disable
> IRQs as that too causes BH to be disabled and is safe in either
> case.
> 
> Thanks to John Linville for discovering this bug and providing
> a patch.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This also seems to work for me.

John

P.S.  As pointed-out elsewhere, my patch neglected to change
synchronize_rcu_bh to synchronize_rcu in netpoll.c.  If some fault
is found w/ Herbert's patch then I can post a modified version of mine.
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
