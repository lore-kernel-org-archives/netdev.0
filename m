From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] net: use bigger pages in __netdev_alloc_frag
Date: Wed, 26 Sep 2012 09:36:22 -0700
Message-ID: <50632F06.1040306@intel.com>
References: <1348650402.5093.176.camel@edumazet-glaptop>  <50632681.40208@intel.com> <1348676085.5093.361.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56960 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab2IZQgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 12:36:15 -0400
In-Reply-To: <1348676085.5093.361.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2012 09:14 AM, Eric Dumazet wrote:
> On Wed, 2012-09-26 at 09:00 -0700, Alexander Duyck wrote:
>
>> One minor thought.  Instead of tracking offset and size why not just
>> work from the top down instead of the bottom up?
>>
>> So instead of starting with the frag offset at 0, why not start it at
>> PAGE_SIZE << order, and then work your way down to 0.  That way you
>> don't need to track both size and offset.
>>
> How do you refill then ? 
>
> (ie setting xxx->offset back to PAGE_SIZE << order)
>
> I am not sure we have direct access to a page order given a struct page
> pointer.
>
> I also like struct page_frag abstraction, because it might allow us
> better code factorization with other frag allocators.
>
> ( skb_append_datato_frags(), sk_page_frag_refill(), ...)

I forgot about the page recycling portion of it.  I was still thinking
of the original implementation that had a fixed page order.  You are
correct, with the page order being dynamic you will have to store size
somewhere.

Thanks,

Alex
