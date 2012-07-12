From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Update alloc frag to reduce get/put page
 usage and recycle pages
Date: Wed, 11 Jul 2012 18:11:08 -0700 (PDT)
Message-ID: <20120711.181108.265166900708992139.davem@davemloft.net>
References: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>
	<20120712001810.26542.61967.stgit@gitlad.jf.intel.com>
	<1342052967.3265.8210.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, alexander.duyck@gmail.com,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672Ab2GLBLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 21:11:09 -0400
In-Reply-To: <1342052967.3265.8210.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jul 2012 02:29:27 +0200

> On Wed, 2012-07-11 at 17:18 -0700, Alexander Duyck wrote:
>> This patch does several things.
>> 
>> First it reorders the netdev_alloc_frag code so that only one conditional
>> check is needed in most cases instead of 2.
>> 
>> Second it incorporates the atomic_set and atomic_sub_return logic from an
>> earlier proposed patch by Eric Dumazet allowing for a reduction in the
>> get_page/put_page overhead when dealing with frags.
>> 
>> Finally it also incorporates the page reuse code so that if the page count
>> is dropped to 0 we can just reinitialize the page and reuse it.
>> 
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
> 
> 
> Hmm, I was working on a version using order-3 pages if available.
> 
> (or more exactly 32768 bytes chunks)
> 
> I am not sure how your version can help with typical 1500 allocations
> (2 skbs per page)

I'd like you two to sort things out before I apply anything, thanks :)
