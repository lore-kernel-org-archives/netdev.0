From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: use bigger pages in __netdev_alloc_frag
Date: Wed, 26 Sep 2012 18:14:45 +0200
Message-ID: <1348676085.5093.361.camel@edumazet-glaptop>
References: <1348650402.5093.176.camel@edumazet-glaptop>
	 <50632681.40208@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64208 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab2IZQOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 12:14:51 -0400
Received: by bkcjk13 with SMTP id jk13so441918bkc.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 09:14:49 -0700 (PDT)
In-Reply-To: <50632681.40208@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-26 at 09:00 -0700, Alexander Duyck wrote:

> One minor thought.  Instead of tracking offset and size why not just
> work from the top down instead of the bottom up?
> 
> So instead of starting with the frag offset at 0, why not start it at
> PAGE_SIZE << order, and then work your way down to 0.  That way you
> don't need to track both size and offset.
> 

How do you refill then ? 

(ie setting xxx->offset back to PAGE_SIZE << order)

I am not sure we have direct access to a page order given a struct page
pointer.

I also like struct page_frag abstraction, because it might allow us
better code factorization with other frag allocators.

( skb_append_datato_frags(), sk_page_frag_refill(), ...)
