From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
Date: Fri, 11 May 2012 01:10:34 -0400 (EDT)
Message-ID: <20120511.011034.557833140906762226.davem@davemloft.net>
References: <1336658065-24851-1-git-send-email-mgorman@suse.de>
	<1336658065-24851-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond.Myklebust@netapp.com, neilb@suse.de, hch@infradead.org,
        a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net
To: mgorman@suse.de
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1336658065-24851-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 10 May 2012 14:54:14 +0100

> It could happen that all !SOCK_MEMALLOC sockets have buffered so
> much data that we're over the global rmem limit. This will prevent
> SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
> from running, which is needed to reduce the buffered data.
> 
> Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

This introduces an invariant which I am not so sure is enforced.

With this change it is absolutely required that once a socket
becomes SOCK_MEMALLOC it must never _ever_ lose that attribute.

Otherwise we can end up liberating global rmem tokens which we never
actually took.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
