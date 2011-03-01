From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 19:53:05 +0800
Message-ID: <20110301115305.GA6984@gondor.apana.org.au>
References: <20110228141322.GF9763@canuck.infradead.org> <1298910174.2941.585.camel@edumazet-laptop> <20110228163742.GH9763@canuck.infradead.org> <1298912869.2941.687.camel@edumazet-laptop> <20110301101955.GI9763@canuck.infradead.org> <1298975602.3284.13.camel@edumazet-laptop> <20110301110708.GJ9763@canuck.infradead.org> <1298977984.3284.15.camel@edumazet-laptop> <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47511 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab1CALx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 06:53:28 -0500
Content-Disposition: inline
In-Reply-To: <1298979909.3284.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 12:45:09PM +0100, Eric Dumazet wrote:
>
> CPU 11 handles all TX completions : Its a potential bottleneck.
> 
> I might ressurect XPS patch ;)

Actually this has been my gripe all along with our TX multiqueue
support.  We should not decide the queue based on the socket, but
on the current CPU.

We already do the right thing for forwarded packets because there
is no socket to latch onto, we just need to fix it for locally
generated traffic.

The odd packet reordering each time your scheduler decides to
migrate the process isn't a big deal IMHO.  If your scheduler
is constantly moving things you've got bigger problems to worry
about.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
