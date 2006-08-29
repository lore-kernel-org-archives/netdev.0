From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/10]: [XFRM]: Dynamic xfrm_state hash table sizing.
Date: Tue, 29 Aug 2006 02:49:50 -0700 (PDT)
Message-ID: <20060829.024950.31643023.davem@davemloft.net>
References: <20060815.043905.79069789.davem@davemloft.net>
	<200608291115.56865.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9906
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964843AbWH2JuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 05:50:07 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200608291115.56865.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 29 Aug 2006 11:15:56 +0200

> This kind of functions are becoming very common and
> duplicated... maybe we can factorize it ?

That's certainly why a subsequent patch in that set moved all of this
to net/xfrm/xfrm_hash.c :-)

Only when my routing cache hash changes are checked in will there be
any similar use outside of the XFRM layer.  I did not put my
routing cache dynamic hash table changes anywhere yet because
frankly the growth logic is incomplete and needs to be in a working
state.

If nobody takes on the task to work on that, and I might not be
strong enough to do this, the dynamic hashing patches for the
routing cache will certainly rot.  We really cannot put those
changes in without good growth logic.

Eric you used to be so active.  Please try to find some free time from
your busy schedule to work on something like this ;-)

> Also, it would be cool to be able to vmalloc()/free_pages hugetlb pages for 
> very large hash tables...

I always wanted to do this on sparc64, especially for modules.  It
requires arch-level support, for sure.

At least in the modules case, it's kind of easy, since you just
preallocate 4MB chunks and then dish out regions within those
chunks.  Something similar could be done to handle hash tables
too, but we'd need to be careful about fragmentation.

