From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] rhashtable: rhashtable_rehash
Date: Mon, 2 Feb 2015 11:16:47 +0000
Message-ID: <20150202111647.GA25964@casper.infradead.org>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150131102329.GA29520@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59144 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172AbbBBLQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 06:16:48 -0500
Content-Disposition: inline
In-Reply-To: <20150131102329.GA29520@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/15 at 09:23pm, Herbert Xu wrote:
> +	new_hash = head_hashfn(ht, new_tbl, entry);
> +
> +	new_bucket_lock = bucket_lock(new_tbl, new_hash);
> +
> +	spin_lock(new_bucket_lock);

I realize this is WIP and not fully worked out yet, therefore just a
thought:

Unless you change this fundamentally then locking just the new bucket
lock based on the new hash is not sufficient when you rehash while growing
as the old bucket will contain entries which will get distributed across
2 buckets in the new table and if we change the seed it will map to
even more buckets. I assume you have an idea how to handle that.

Let me know if any of the patches proposed in "rhashtable fixes" don't
conflict with your intended changes and I will resubmit those separately.
