From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix leak of expired xfrm_states
Date: Mon, 26 Nov 2007 23:46:25 +0800
Message-ID: <20071126154625.GI28022@gondor.apana.org.au>
References: <474AE0B7.5010709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4161 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751977AbXKZPqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:46:31 -0500
Content-Disposition: inline
In-Reply-To: <474AE0B7.5010709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 04:05:27PM +0100, Patrick McHardy wrote:
> This patch fixes a xfrm_state leak, which appears to be a
> regression from the reference count simplifications.

I was going to say this was a good find :)

But digging deeper it seems that it might not be a bug after
all.  Even though the ref count on x may now drop to zero, it
won't be freed until del_timer_sync returns which should be
sufficient, no?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
