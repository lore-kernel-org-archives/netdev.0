From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
Date: Wed, 20 Jun 2012 11:22:35 -0400
Message-ID: <4FE1EABB.5060105@redhat.com>
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1340185081-22525-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> It could happen that all !SOCK_MEMALLOC sockets have buffered so
> much data that we're over the global rmem limit. This will prevent
> SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
> from running, which is needed to reduce the buffered data.
>
> Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.
> Once this change it applied, it is important that sockets that set
> SOCK_MEMALLOC do not clear the flag until the socket is being torn down.
> If this happens, a warning is generated and the tokens reclaimed to
> avoid accounting errors until the bug is fixed.
>
> [davem@davemloft.net: Warning about clearing SOCK_MEMALLOC]
> Signed-off-by: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman<mgorman@suse.de>
> Acked-by: David S. Miller<davem@davemloft.net>

Acked-by: Rik van Riel<riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
