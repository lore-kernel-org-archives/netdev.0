From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix leak of expired xfrm_states
Date: Mon, 26 Nov 2007 23:54:08 +0800
Message-ID: <20071126155408.GA29097@gondor.apana.org.au>
References: <474AE0B7.5010709@trash.net> <20071126154625.GI28022@gondor.apana.org.au> <474AEB8E.9040903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4310 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752030AbXKZPyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:54:19 -0500
Content-Disposition: inline
In-Reply-To: <474AEB8E.9040903@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 04:51:42PM +0100, Patrick McHardy wrote:
>
> It actually won't get freed at all currently since nothing is
> calling __xfrm_state_destroy(). __xfrm_state_delete() uses
> __xfrm_state_put(), which only decrements the refcount, but
> doesn't perform destruction.
> 
> This is visible when looking at the xfrm[46]_mode_{tunnel,transport}
> module reference counts, they climb higher and higher over time.

Oh I see.  How about just removing those double underscores then?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
