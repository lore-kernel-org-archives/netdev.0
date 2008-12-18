From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
	encapsulation mode
Date: Fri, 19 Dec 2008 07:54:06 +1100
Message-ID: <20081218205406.GA451@gondor.apana.org.au>
References: <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au> <1229603816.10402.178.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41176 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752558AbYLRUyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 15:54:13 -0500
Content-Disposition: inline
In-Reply-To: <1229603816.10402.178.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 01:36:56PM +0100, Martin Willi wrote:
> 
> >From the key manager perspective, I can enable or disable UDP
> encapsulation, fine. I decide locally what I'll use for outgoing
> packets. But how should I know what the peer uses? I can't, it isn't
> negotiated. It is, by the standard, perfectly valid to send UDP
> encapsulated packets if the peer wants to do so. And there is no need to
> communicate this to the key manager, there is actually no such mechanism
> in IKEv2. Therefore I need the kernel to accept packet, encapsulated or
> not.

Even if the kernel did accept such packets, there is no guarantee
that your return traffic will make it back to the other side because
stateful firewalls may be present.

Responding with unencapsulated ESP traffic when the peer is sending
you UDP-encapsulated traffic is just not going to fly.

BTW I think the IKEv2 draft has stuffed it up on this one (though
luckily it hasn't made it to RFC yet).  I'll open a report on it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
