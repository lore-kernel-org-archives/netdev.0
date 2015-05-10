From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] Refactor netdev page frags and move them into mm/
Date: Sun, 10 May 2015 19:17:58 -0400 (EDT)
Message-ID: <20150510.191758.2130017622255857830.davem@davemloft.net>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 eric.dumazet@gmail.com
To: alexander.h.duyck@redhat.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:11:34 -0700

> This patch series addresses several things.
> 
> First I found an issue in the performance of the pfmemalloc check from
> build_skb.  To work around it I have provided a cached copy of pfmemalloc
> to be used in __netdev_alloc_skb and __napi_alloc_skb.
> 
> Second I moved the page fragment allocation logic into the mm tree and
> added functionality for freeing page fragments.  I had to fix igb before I
> could do this as it was using a reference to NETDEV_FRAG_PAGE_MAX_SIZE
> incorrectly.
> 
> Finally I went through and replaced all of the duplicate code that was
> calling put_page and replaced it with calls to skb_free_frag.
> 
> With these changes in place a simple receive and drop test increased from a
> packet rate of 8.9Mpps to 9.8Mpps.  The gains breakdown as follows:
> 
> 8.9Mpps	Before			9.8Mpps	After
> ------------------------	------------------------
> 7.8%	put_compound_page	9.1%	__free_page_frag
> 3.9%	skb_free_head
> 1.1%	put_page
> 
> 4.9%	build_skb		3.8%	__napi_alloc_skb
> 2.5%	__alloc_rx_skb
> 1.9%	__napi_alloc_skb

I like this series, but again I need to see feedback from some
mm folks before I can consider applying it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
