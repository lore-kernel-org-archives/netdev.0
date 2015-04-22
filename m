From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 1/2] rhashtable: Schedule async resize when sync
 realloc fails
Date: Wed, 22 Apr 2015 08:36:34 +0800
Message-ID: <20150422003634.GA5724@gondor.apana.org.au>
References: <cover.1429620438.git.tgraf@suug.ch>
 <4f55f5c9abd6b09ed44f0da3f0e72a10040e8278.1429620438.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38714 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933767AbbDVAgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 20:36:50 -0400
Content-Disposition: inline
In-Reply-To: <4f55f5c9abd6b09ed44f0da3f0e72a10040e8278.1429620438.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2015 at 02:55:34PM +0200, Thomas Graf wrote:
> When rhashtable_insert_rehash() fails with ENOMEM, this indicates that
> we can't allocate the necessary memory in the current context but the
> limits as set by the user would still allow to grow.
> 
> Thus attempt an async resize in the background where we can allocate
> using GFP_KERNEL which is more likely to succeed. The insertion itself
> will still fail to indicate pressure.
> 
> This fixes a bug where the table would never continue growing once the
> utilization is above 100%.
> 
> Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Good catch.  But I think this call should happen in
rhashtable_insert_rehash since it's on the slow-path.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
