From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Wed, 26 Mar 2008 07:55:36 +0800
Message-ID: <20080325235536.GB30298@gondor.apana.org.au>
References: <47E946C8.6020006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35968 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753166AbYCZBxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 21:53:12 -0400
Content-Disposition: inline
In-Reply-To: <47E946C8.6020006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2008 at 02:39:04PM -0400, Hideo AOKI wrote:
> Hello,
> 
> This patch set fixes a potential bug in pskb_expand_head().
> 
> Current pskb_expand_head() doesn't change truesize, while it
> reallocates memory. Then, if argument nhead or ntail aren't 0, caller
> must update truesize.
> 
> We had this bug at audit_expand() in January and fixed it as commit
> 406a1d868001423c85a3165288e566e65f424fe6. However, some drivers and
> subsystems still use pskb_expand_head() without updating truesize.

Drivers usually aren't supposed to change truesize so doing
this would actually create bugs.

> In addition, there is another problem to update truesise. Since
> pskb_expand_head() aligns memory size before reallocation, caller
> functions may not update turesize correctly if they just add nhaad
> and ntail to turesize.

That should be fixable by making sure that nhead + ntail is
aligned.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
