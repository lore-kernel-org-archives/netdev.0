From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 19:36:59 +0800
Message-ID: <20110228113659.GA20726@gondor.apana.org.au>
References: <20110225.112019.48513284.davem@davemloft.net> <20110226005718.GA19889@gondor.apana.org.au> <20110227110205.GE9763@canuck.infradead.org> <20110227110614.GA6246@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:36729 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325Ab1B1LhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 06:37:17 -0500
Content-Disposition: inline
In-Reply-To: <20110227110614.GA6246@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 27, 2011 at 07:06:14PM +0800, Herbert Xu wrote:
> I'm working on this right now.

OK I think I was definitely on the right track.  With the send
patch made lockless I now get numbers which are even better than
those obtained with running named with multiple sockets.  That's
right, a single socket is now faster than what multiple sockets
were without the patch (of course, multiple sockets may still
faster with the patch vs. a single socket for obvious reasons,
but I couldn't measure any significant difference).

Also worthy of note is that prior to the patch all CPUs showed
idleness (lazy bastards!), with the patch they're all maxed out.

In retrospect, the idleness was simply the result of the socket
lock scheduling away and was an indication of lock contention.

Here are the patches I used.  Please don't them yet as I intend
to clean them up quite a bit.

But please do test them heavily, especially if you have an AMD
NUMA machine as that's where scalability problems really show
up.  Intel tends to be a lot more forgiving.  My last AMD machine
blew up years ago :)

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
