From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/1]: SAs created although tmpl->optional set
Date: Mon, 19 Nov 2007 17:49:03 +0800
Message-ID: <20071119094903.GA4246@gondor.apana.org.au>
References: <200711190853.lAJ8ro9f006107@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4955 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751599AbXKSJtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 04:49:09 -0500
Content-Disposition: inline
In-Reply-To: <200711190853.lAJ8ro9f006107@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 02:53:50AM -0600, Joy Latten wrote:
> Although tmpl->optional is set, kernel still attempts
> to create a set of SAs. 

Heh I made the same mistake when I first read this piece of
code too :) The optional flag isn't saying that it doesn't need
to be protected, but rather that the SA may not be present on
input.  It's only used for IPComp where we may skip the IPComp
if the data is not compressible.

In other words the optional flag is really only meaningful on
inbuond policy checks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
