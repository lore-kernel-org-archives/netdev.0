From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Mon, 29 Mar 2010 20:45:30 +0800
Message-ID: <20100329124530.GA24864@gondor.apana.org.au>
References: <20100329111025.GA23927@gondor.apana.org.au> <4BB08D96.8090909@iki.fi> <20100329113225.GA24159@gondor.apana.org.au> <4BB09178.8050501@iki.fi> <20100329115701.GA24367@gondor.apana.org.au> <4BB0970E.7060405@iki.fi> <20100329121124.GA24470@gondor.apana.org.au> <4BB09AFD.4050304@iki.fi> <20100329122547.GA24666@gondor.apana.org.au> <4BB09E35.8070402@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48109 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752067Ab0C2Mph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 08:45:37 -0400
Content-Disposition: inline
In-Reply-To: <4BB09E35.8070402@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 03:33:57PM +0300, Timo Ter=E4s wrote:
>
> So we fix up all the callers of xfrm_policy_kill to check properly
> result of __xfrm_policy_unlink(). Since the policy can be only
> once deleted from the hashes (it's protected by xfrm_policy_lock)
> return value of __xfrm_policy_unlink() can be used to give
> responsibility of calling xfrm_policy_kill() exactly once.
>
> I thought this was already being done, but apparently it's not
> the case.

Actually you're right.  This should be the case as otherwise
we'd be triggering that WARN_ON.

Since it hasn't triggered in the five years that it's been around,
I suppose we can now remove it along with the lock.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
