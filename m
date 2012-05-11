From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/17] netvm: Allow the use of __GFP_MEMALLOC by
 specific sockets
Date: Fri, 11 May 2012 00:50:34 -0400 (EDT)
Message-ID: <20120511.005034.837005484911910521.davem@davemloft.net>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
	<1336657510-24378-10-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl,
        michaelc@cs.wisc.edu, emunson@mgebm.net
To: mgorman@suse.de
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1336657510-24378-10-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 10 May 2012 14:45:02 +0100

> Allow specific sockets to be tagged SOCK_MEMALLOC and use
> __GFP_MEMALLOC for their allocations. These sockets will be able to go
> below watermarks and allocate from the emergency reserve. Such sockets
> are to be used to service the VM (iow. to swap over). They must be
> handled kernel side, exposing such a socket to user-space is a bug.
> 
> There is a risk that the reserves be depleted so for now, the
> administrator is responsible for increasing min_free_kbytes as
> necessary to prevent deadlock for their workloads.
> 
> [a.p.zijlstra@chello.nl: Original patches]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

After sk_allocation() is adjusted to be sk_gfp_atomic() as I suggested
in my feedback for patch #8, this is fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
