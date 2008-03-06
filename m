From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]kernel crashes when using aes-xcbc-mac with IPsec
Date: Thu, 6 Mar 2008 19:29:46 +0800
Message-ID: <20080306112946.GA7083@gondor.apana.org.au>
References: <200803051451.m25EpKv8016389@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel, davem@davemloft.net,
	netdev@vger.kernel.org
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40005 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755962AbYCFLaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 06:30:10 -0500
Content-Disposition: inline
In-Reply-To: <200803051451.m25EpKv8016389@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2008 at 08:51:20AM -0600, Joy Latten wrote:
> When using aes-xcbc-mac for authentication in IPsec, 
> the kernel crashes. It seems this algorithm doesn't 
> account for the space IPsec may make in scatterlist for authtag.
> Thus when crypto_xcbc_digest_update2() gets called,
> nbytes may be less than sg[i].length. 
> Since nbytes is an unsigned number, it wraps
> at the end of the loop allowing us to go back 
> into loop and causing crash in memcpy.
> 
> I used update function in digest.c to model this fix.
> Please let me know if it looks ok.
> 
> regards,
> Joy 
> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>

Good catch! Patch applied, thanks Joy.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
