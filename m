From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 5/13] crypto: testmgr - Switch to new AEAD interface
Date: Fri, 5 Jun 2015 11:57:47 +0800
Message-ID: <20150605035747.GC527@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <E1YviM1-0000xu-GV@gondolin.me.apana.org.au>
 <5570CDF7.4090308@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56180 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbFEFVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 01:21:16 -0400
Content-Disposition: inline
In-Reply-To: <5570CDF7.4090308@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 04, 2015 at 03:15:19PM -0700, Tadeusz Struk wrote:
> Hi Herbert,
> On 05/22/2015 01:30 AM, Herbert Xu wrote:
> > This patch makes use of the new AEAD interface which uses a single
> > SG list instead of separate lists for the AD and plain text.
> 
> The fact the src and assoc point to the same sgl causes some inconsistency. The input I'm getting is:
> req->old = 1
> req->src_nents = 1
> req->src_len = 80
> req->dst_nents = 1
> req->dst_len = 80
> req->assoclen = 0
> 
> but
> 
> req->assoc_nents = 1
> req->assoc_len = 80
> 
> I presume req->assoc is obsolete now and drivers need to use req->assoclen. right?
> Currently I just loop over req->assoc to get the AD.

Existing AEAD implementations should be completely unaware of
the new interface because we recreate the old req->assoc in the
crypto API.

However, if you are creating a new AEAD implementation then yes
you should stop using req->assoc and fetch it from req->src instead.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
