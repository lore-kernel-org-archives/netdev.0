From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 1/2] rhashtable: Schedule async resize when sync
 realloc fails
Date: Wed, 22 Apr 2015 15:43:44 +0800
Message-ID: <20150422074344.GA8882@gondor.apana.org.au>
References: <cover.1429688383.git.tgraf@suug.ch>
 <b5b3fa09e48a245bcbe9d9b38d271619f4c2fd80.1429688383.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59771 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933639AbbDVHnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:43:52 -0400
Content-Disposition: inline
In-Reply-To: <b5b3fa09e48a245bcbe9d9b38d271619f4c2fd80.1429688383.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 09:41:45AM +0200, Thomas Graf wrote:
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

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
