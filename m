From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] rhashtable: Fix race between rehashing and
 readers
Date: Fri, 13 Mar 2015 08:50:02 +1100
Message-ID: <20150312215002.GB20117@gondor.apana.org.au>
References: <20150312110749.GA19285@gondor.apana.org.au>
 <20150312133749.GB21620@casper.infradead.org>
 <20150312163348.GD5378@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:57637 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbbCLVuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 17:50:04 -0400
Content-Disposition: inline
In-Reply-To: <20150312163348.GD5378@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 04:33:48PM +0000, Thomas Graf wrote:
> Rehashing can occur in parallel to readers. Readers are aware of this
> situation so new readers are allowed while the rehashing is in
> process. Existing readers may have already fetched the tbl and
> future_tbl and may thus assume no rehashing is in progress. The
> rehashing must thus wait for all existing readers to complete after
> publihsing the future_tbl to make sure all parallel readers see the
> table before we start moving entries.
> 
> Fixes: aa34a6cb0478 ("rhashtable: Add arbitrary rehash function")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> Herbert: This is what I think is needed to fix this properly.

Nack.  Please see my previous email.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
