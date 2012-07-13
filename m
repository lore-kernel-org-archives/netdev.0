From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH] net: Update alloc frag to reduce get/put page usage
 and recycle pages
Date: Fri, 13 Jul 2012 02:59:40 -0700 (PDT)
Message-ID: <20120713.025940.1570303494768484854.davem@davemloft.net>
References: <20120713001922.27393.1358.stgit@gitlad.jf.intel.com>
	<1342170394.3265.8339.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	alexander.duyck@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754557Ab2GMJ7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 05:59:45 -0400
In-Reply-To: <1342170394.3265.8339.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Jul 2012 11:06:34 +0200

> On Thu, 2012-07-12 at 17:23 -0700, Alexander Duyck wrote:
>> This patch is meant to help improve performance by reducing the number of
>> locked operations required to allocate a frag on x86 and other platforms.
>> This is accomplished by using atomic_set operations on the page count
>> instead of calling get_page and put_page.  It is based on work originally
>> provided by Eric Dumazet.
>> 
>> In addition it also helps to reduce memory overhead when using TCP.  This
>> is done by recycling the page if the only holder of the frame is the
>> netdev_alloc_frag call itself.  This can occur when skb heads are stolen by
>> either GRO or TCP and the driver providing the packets is using paged frags
>> to store all of the data for the packets.
>> 
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
