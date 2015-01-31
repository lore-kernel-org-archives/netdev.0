From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/6] rhashtable: Use a single bucket lock for sibling
 buckets
Date: Sat, 31 Jan 2015 15:34:37 +1100
Message-ID: <20150131043436.GA27564@gondor.apana.org.au>
References: <14d537500868b4ff0396168cf9d5db95d327c128.1422576760.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ying.xue@windriver.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:33815 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458AbbAaEen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 23:34:43 -0500
Content-Disposition: inline
In-Reply-To: <14d537500868b4ff0396168cf9d5db95d327c128.1422576760.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> wrote:
> rhashtable currently allows to use a bucket lock per bucket. This
> requires multiple levels of complicated nested locking because when
> resizing, a single bucket of the smaller table will map to two
> buckets in the larger table. So far rhashtable has explicitly locked
> both buckets in the larger table.
> 
> By excluding the highest bit of the hash from the bucket lock map and
> thus only allowing locks to buckets in a ratio of 1:2, the locking
> can be simplified a lot without losing the benefits of multiple locks.
> Larger tables which benefit from multiple locks will not have a single
> lock per bucket anyway.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thomas, could you please hold off on these changes? They totally
conflict with my rehash work, which is going to render these changes
moot anyway since it'll completely change how expansion/shrinking
works.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
