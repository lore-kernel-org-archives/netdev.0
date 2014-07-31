From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Header length compution function
Date: Wed, 30 Jul 2014 18:39:07 -0700 (PDT)
Message-ID: <20140730.183907.1435538533126954589.davem@davemloft.net>
References: <20140729.215853.2058634690190963314.davem@davemloft.net>
	<1406703644.3178.30.camel@edumazet-glaptop2.roam.corp.google.com>
	<53D90099.6040906@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, amirv@mellanox.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com, idos@mellanox.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbaGaBjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 21:39:08 -0400
In-Reply-To: <53D90099.6040906@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 30 Jul 2014 07:26:33 -0700

> It wasn't that I don't trust the core function.  We already had some of
> our own code floating around for the out-of-tree LRO and so I simply
> made use of that as it allowed for code reuse in our driver.

It would be nice if this code were converted to use the generic
infrastructure, at some point at least.

> I almost wonder if it wouldn't be worth while to move data_len and len
> closer to the end of the sk_buff and perhaps create a structure within
> the structure so that you could partition off all of the bits that we
> don't need for these kind of simple operations.

That is something we can certainly look into in the long term.

But it's also not all that desirable to try to extricate the
non-linear handling.  It took us a long time to get all the code to
handle non-linear SKBs :-)

And in that case you have the issue of the fragmenting state being
separate in the skb_shared_info.

Anyways, a discussion for a different thread I think.

I don't think my proposed patch is a bad trade off.  Where we have the
__skb_header_pointer() thing that takes preloaded pointers and header
length values.  It adds only one test which frankly should never
trigger and can be moved down into skb_copy_bits() or similar.
