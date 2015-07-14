From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 1/3] rhashtable: Add a function for in order
 insertion in buckets
Date: Tue, 14 Jul 2015 17:57:21 +0800
Message-ID: <20150714095721.GA22264@gondor.apana.org.au>
References: <1436834353-1851565-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
	kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41755 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514AbbGNJ5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 05:57:33 -0400
Content-Disposition: inline
In-Reply-To: <1436834353-1851565-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> The obj_orderfn function may be specified in the parameters for a
> rhashtable. When inserting an element this function is used to order
> objects in a bucket list (greatest to least ordering value).This
> allows entries to have wild card fields, where entries with
> more specific information match are placed first in the bucket.
> When a lookup is done, the first match found will contain
> the most specific match.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

I think this is fundamentally broken with respect to rehashing.
During a rehash you're going to have some elements in the old table
and some in the new table.  At which point all your ordering
guarantees go out of the window.

I actually need something quite similar for IPsec.  What I was
planning on doing is have the actual objects hang off an ordered
list object.  The ordered list would then be the thing that you
insert into rhashtable.  This means that during rehashing they
get moved atomically.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
