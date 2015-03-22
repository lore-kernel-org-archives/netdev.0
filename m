From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: arp_hash
Date: Mon, 23 Mar 2015 08:34:08 +1100
Message-ID: <20150322213408.GC7925@gondor.apana.org.au>
References: <20150322114204.GA5010@gondor.apana.org.au>
 <20150322.125458.2054837991708165397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46506 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbbCVVeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 17:34:11 -0400
Content-Disposition: inline
In-Reply-To: <20150322.125458.2054837991708165397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 12:54:58PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sun, 22 Mar 2015 22:42:04 +1100
> 
> > If the attacker can somehow get the pointer value of the device
> > then all is lost since they could set any number of the low bits
> > of val to zero.
> 
> This "attacker" with access to your physcial network?

It could be a malicious local user, or it could be any host
if you are a router.
 
> I'm all for shifting the device pointer down a few bits to get more
> entropy, but I don't completely agree with the rest of your
> objections.

Granted for IPv4 you're not going to be in big trouble unless
you have a very large network (e.g. /16) configured.  But with
IPv6 this could seriously hose your box.

> This hash function has to be as fast as possible, even jhash{,2} is
> too expensive.

So what scales we are talking about, twice, three times? Have you
considered more modern hashes such as SipHash or SpookyHash
(successor to jhash/lookup3 and supposedly faster)?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
