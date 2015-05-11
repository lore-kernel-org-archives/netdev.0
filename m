From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] net: Use cached copy of pfmemalloc to avoid
 accessing page
Date: Sun, 10 May 2015 20:52:13 -0400 (EDT)
Message-ID: <20150510.205213.202914226916051307.davem@davemloft.net>
References: <20150507041140.1873.58533.stgit@ahduyck-vm-fedora22>
	<20150510.191851.414324528131774160.davem@davemloft.net>
	<554FF14B.4050901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	linux-mm@kvack.org, akpm@linux-foundation.org,
	eric.dumazet@gmail.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbbEKAwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 20:52:18 -0400
In-Reply-To: <554FF14B.4050901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sun, 10 May 2015 17:01:15 -0700

> The reason for the difference between the two is that in the case of
> netdev_alloc_skb/frag the netdev_alloc_cache can only be accessed with
> IRQs disabled, whereas in the napi_alloc_skb case we can access the
> napi_alloc_cache at any point in the function.  Either way I am going
> to be stuck with differences because of the local_irq_save/restore
> that must be called when accessing the page frag cache that doesn't
> exist in the napi case.

I see, thanks for explaining.
