From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: Fix remove logic to avoid cross
 references between buckets
Date: Fri, 06 Feb 2015 15:20:18 -0800 (PST)
Message-ID: <20150206.152018.832752279014053975.davem@davemloft.net>
References: <20150205101954.GA24388@casper.infradead.org>
	<54D42892.3030808@windriver.com>
	<20150206160843.GA31371@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbBFXUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 18:20:19 -0500
In-Reply-To: <20150206160843.GA31371@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 6 Feb 2015 16:08:43 +0000

> The remove logic properly searched the remaining chain for a matching
> entry with an identical hash but it did this while searching from both
> the old and new table. Instead in order to not leave stale references
> behind we need to:
> 
>  1. When growing and searching from the new table:
>     Search remaining chain for entry with same hash to avoid having
>     the new table directly point to a entry with a different hash.
> 
>  2. When shrinking and searching from the old table:
>     Check if the element after the removed would create a cross
>     reference and avoid it if so.
> 
> These bugs were present from the beginning in nft_hash.
> 
> Also, both insert functions calculated the hash based on the mask of
> the new table. This worked while growing. Wwhile shrinking, the mask
> of the inew table is smaller than the mask of the old table. This lead
> to a bit not being taken into account when selecting the bucket lock
> and thus caused the wrong bucket to be locked eventually.
> 
> Fixes: 7e1e77636e36 ("lib: Resizable, Scalable, Concurrent Hash Table")
> Fixes: 97defe1ecf86 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Reported-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
