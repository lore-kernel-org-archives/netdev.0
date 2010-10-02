From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv3 net-next-2.6 3/5] XFRM,IPv6: Add IRO src/dst address
	remapping XFRM types and i/o handlers
Date: Sat, 2 Oct 2010 18:32:05 +0800
Message-ID: <20101002103205.GA3879@gondor.apana.org.au>
References: <cover.1285749610.git.arno@natisbad.org> <fd4eec3c9486c46b535e89ceed479c7536f51fb9.1285749610.git.arno@natisbad.org> <20100929.201618.241458205.davem@davemloft.net> <87iq1k99vk.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39216 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005Ab0JBKcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Oct 2010 06:32:19 -0400
Content-Disposition: inline
In-Reply-To: <87iq1k99vk.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 02, 2010 at 12:17:35PM +0200, Arnaud Ebalard wrote:
>
> and I see no reason not to keep the lock we have on the state until the
> end of the function when the state is valid (when we break), instead of
> releasing it to get it again later. Something like the following would
> allow removing the spin_lock()/spin_unlock() calls from all mip6 input
> handlers (mip6_{destopt,rthdr,iro_src,iro_dst}_input()):

No I moved the state lock down precisely because it should not
be taken at a higher level as that breaks asynchronous IPsec
processing and the fact that it isn't needed in most places.

If your code needs it then you should take it rather than impose
it on real IPsec users.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
