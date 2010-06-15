From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH net-next-2.6] loopback: Implement 64bit stats on 32bit
 arches
Date: Tue, 15 Jun 2010 16:49:23 +1000
Message-ID: <20100615064923.GF6138@laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
 <20100614.231412.39191304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33192 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085Ab0FOGt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 02:49:28 -0400
Content-Disposition: inline
In-Reply-To: <20100614.231412.39191304.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 14, 2010 at 11:14:12PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 14 Jun 2010 17:59:22 +0200
> 
> > Uses a seqcount_t to synchronize stat producer and consumer, for packets
> > and bytes counter, now u64 types.
> > 
> > (dropped counter being rarely used, stay a native "unsigned long" type)
> > 
> > No noticeable performance impact on x86, as it only adds two increments
> > per frame. It might be more expensive on arches where smp_wmb() is not
> > free.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied, but I suspect we might end up eventually needing to
> abstract this kind of technique in a common place so other
> spots can use it.

Check i_size stuff in include/linux/fs.h if you consider doing this.
And keep preempt in mind too. I assume you can't be preempted at this
point, but if you're prone to change the locking, it might be worth
the (small) cost of doing explicit preempt_disable() (and maybe to
help the sanity of the -rt guys too).

