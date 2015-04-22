From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 2/2] rhashtable: Do not schedule more than one rehash
 if we can't grow further
Date: Wed, 22 Apr 2015 08:37:45 +0800
Message-ID: <20150422003744.GB5724@gondor.apana.org.au>
References: <cover.1429620438.git.tgraf@suug.ch>
 <8f90c3e52b4930ae24627dd193cf3fc26878bdb9.1429620438.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40897 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965084AbbDVAhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 20:37:54 -0400
Content-Disposition: inline
In-Reply-To: <8f90c3e52b4930ae24627dd193cf3fc26878bdb9.1429620438.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2015 at 02:55:35PM +0200, Thomas Graf wrote:
> The current code currently only stops inserting rehashes into the
> chain when no resizes are currently scheduled. As long as resizes
> are scheduled and while inserting above the utilization watermark,
> more and more rehashes will be scheduled.
> 
> This lead to a perfect DoS storm with thousands of rehashes
> scheduled which lead to thousands of spinlocks to be taken
> sequentially.
> 
> Instead, only allow either a series of resizes or a single rehash.
> Drop any further rehashes and return -EBUSY.
> 
> Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
