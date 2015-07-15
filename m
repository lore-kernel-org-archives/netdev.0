From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next 2/3] rhashtable: Add a function for in order
 insertion and lookup in buckets
Date: Wed, 15 Jul 2015 13:54:12 +0800
Message-ID: <20150715055411.GA31926@gondor.apana.org.au>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
 <1436917549-3666965-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
	kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:39289 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbbGOFyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 01:54:24 -0400
Content-Disposition: inline
In-Reply-To: <1436917549-3666965-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 04:45:48PM -0700, Tom Herbert wrote:
> The obj_orderfn function may be specified in the parameters for a
> rhashtable. When inserting an element this function is used to order
> objects in a bucket list (greatest to least ordering value).This
> allows entries to have wild card fields, where entries with
> more specific information match are placed first in the bucket.
> When a lookup is done, the first match found will contain
> the most specific match.
> 
> In order to maintain ordering guarantees during rehash, the
> rhashtable_lookup_ordered_cmpfn was added. This function will check
> future tables for matches that would have a greater insertion order
> than a match found in an older table.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

There is another problem with exposing rhashtable directly to these
duplicate entries.  It breaks the logic on when to resize.  In the
worst case on a server with a single port you can end up with a
large hash table where everything is stored in a single chain.

Granted you can work around this by teaching rhashtable to count
identical entries as a single entry.  But I really think it's much
easier to just have this logic sit on top of rhashtable instead of
inside it.

The memory cost is merely 8 bytes per local port, is it really too
much?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
