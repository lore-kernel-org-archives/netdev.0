From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] xfrm: Fix inter family IPsec tunnel handling again
Date: Tue, 8 Jul 2008 18:40:22 +0800
Message-ID: <20080708104022.GA26280@gondor.apana.org.au>
References: <20080705071950.GA26532@secunet.com> <20080705115654.GA18290@gondor.apana.org.au> <20080708095335.GP9549@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59561 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753980AbYGHKkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:40:39 -0400
Content-Disposition: inline
In-Reply-To: <20080708095335.GP9549@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2008 at 11:53:35AM +0200, Steffen Klassert wrote:
>
> Actually we are setting sel.family to the outer mode family if it is 
> unspecified from userspace, so it is always specified at this point. This was 
> changed by 
> commit bcf0dda8 ([XFRM]: xfrm_user: fix selector family initialization)
> because openswan seems to have problems if sel.family is not initialized.
> 
> But now the checks for AF_UNSPEC that are introduced by 
> commit df9dcb45 ([IPSEC]: Fix inter address family IPsec tunnel handling)
> return false. So the code that tries to choose for the right inner mode if
> sel.family was not specified from userspace is not executed and an 
> inter family tunnel does not work in this case.

I discussed this with Miyazawa-san earlier in the year.  In order
to maintain backwards compatibility, the use of AF_UNSPEC needs to
be combined with an SA flag.  So let's create a new flag that can
be set by the applications which needs the AF_UNSPEC behaviour.

That way you get what you want without breaking existing users such
as Openswan.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
