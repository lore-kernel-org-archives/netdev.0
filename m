From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix leak of expired xfrm_states
Date: Tue, 27 Nov 2007 00:22:23 +0800
Message-ID: <20071126162223.GA29293@gondor.apana.org.au>
References: <474AE0B7.5010709@trash.net> <20071126154625.GI28022@gondor.apana.org.au> <474AEB8E.9040903@trash.net> <20071126155408.GA29097@gondor.apana.org.au> <474AEC91.5090907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4974 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751088AbXKZQW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 11:22:28 -0500
Content-Disposition: inline
In-Reply-To: <474AEC91.5090907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 04:56:01PM +0100, Patrick McHardy wrote:
>
> That should work as long as we keep the del_timer_sync to avoid
> a use-after-free. It seems a bit fragile though.

Well we're relying on the del_timer_sync already to avoid the
ref count on the timer.  Otherwise if the admin deletes the
SA while the timer is running it'll go up in smoke too.

If you look in the history you'll find that the same patch
that removed the ref count on the timer introduced the call
to del_timer_sync :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
