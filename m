From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: use bigger pages in
 __netdev_alloc_frag
Date: Thu, 27 Sep 2012 19:30:28 -0400 (EDT)
Message-ID: <20120927.193028.2013768669601059052.davem@davemloft.net>
References: <1348676085.5093.361.camel@edumazet-glaptop>
	<50632F06.1040306@intel.com>
	<1348678017.5093.371.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org, bcrl@kvack.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756160Ab2I0Xaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:30:30 -0400
In-Reply-To: <1348678017.5093.371.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Sep 2012 18:46:57 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> We currently use percpu order-0 pages in __netdev_alloc_frag
> to deliver fragments used by __netdev_alloc_skb()
> 
> Depending on NIC driver and arch being 32 or 64 bit, it allows a page to
> be split in several fragments (between 1 and 8), assuming PAGE_SIZE=4096
> 
> Switching to bigger pages (32768 bytes for PAGE_SIZE=4096 case) allows :
> 
> - Better filling of space (the ending hole overhead is less an issue)
> 
> - Less calls to page allocator or accesses to page->_count
> 
> - Could allow struct skb_shared_info futures changes without major
>   performance impact.
> 
> This patch implements a transparent fallback to smaller
> pages in case of memory pressure.
> 
> It also uses a standard "struct page_frag" instead of a custom one.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Benjamin LaHaise <bcrl@kvack.org>

Applied.
