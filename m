From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not) redundant?
Date: Sun, 27 Jul 2008 12:48:11 +0800
Message-ID: <E1KMyB1-00006Y-00@gondolin.me.apana.org.au>
References: <20080726.003617.265743493.davem@davemloft.net>
Cc: gerrit@erg.abdn.ac.uk, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51540 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752890AbYG0Esa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 00:48:30 -0400
In-Reply-To: <20080726.003617.265743493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> What if the lower protocol doesn't have a header that it
> at least 8 bytes? :-)

When such a protocol enters our tree then we can undo this patch :)

Seriously apart from raw sockets it isn't possible to generate
anything with less than 8 bytes in the IP payload.  As our raw
error handler is separate anyway all we have to do is move the
common check below the raw handler and then we can proceed to
remove the protocol-specific checks as Gerrit proposed.

The stastic is just an oversight AFAICS from looking at git history.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
