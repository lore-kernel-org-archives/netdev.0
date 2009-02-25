From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Wed, 25 Feb 2009 14:19:03 +0800
Message-ID: <20090225061902.GA32430@gondor.apana.org.au>
References: <49A4D5D5.5090602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39104 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756596AbZBYGTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 01:19:07 -0500
Content-Disposition: inline
In-Reply-To: <49A4D5D5.5090602@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2009 at 06:23:33AM +0100, Patrick McHardy wrote:
>
> An easy fix would be to keep track of whether sysctl unregistration
> is in progress in IPv4/IPv6 and ignore new requests from that point
> on. Its not very elegant though, so I was wondering whether anyone
> has a better suggestion.

We could make the unregistration asynchronous and invoke a callback
when it's done.  Then we can simply hold a net_device refcount and
relinquish it in the callback.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
