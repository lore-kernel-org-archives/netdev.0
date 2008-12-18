From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP  encapsulation mode
Date: Thu, 18 Dec 2008 11:35:31 +0100
Message-ID: <1229596531.10402.121.camel@martin>
References: <1228396731.1643.57.camel@martin>
	 <E1LD9rC-0007y7-KY@gondolin.me.apana.org.au>
	 <20081217.194942.01082060.davem@davemloft.net>
	 <20081218035758.GA31610@gondor.apana.org.au>
	 <20081218041419.GA11722@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km23152-01.keymachine.de ([87.118.114.125]:37109 "EHLO
	km23152-01.keymachine.de" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750753AbYLRKf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 05:35:59 -0500
Received: from localhost (km23152-01.keymachine.de [127.0.0.1])
	by km23152-01.keymachine.de (Postfix) with SMTP id 6B99D30A8010
	for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 11:35:36 +0100 (CET)
In-Reply-To: <20081218041419.GA11722@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

> This can't work as ESP relies on this check.  Now that it's gone
> ESP may touch a UDP header which doesn't exist.

Hm, this worked perfectly fine in my tests...

> ... when your addresses change
> you have to renegotiate with the other side to ensure that this
> isn't some kind of an attack.  Afterwards you have to recreate
> the SAs at which point you can easily set the encapsulation to
> whatever it should be.

Such address changes are recorded in the IKEv2 daemon and addresses are
updated through MOBIKE (RFC4555). Each peer updates its SA using the new
address. 

> The only time when you need this patch is if the other side
> unilaterally switched from NAT-T to no NAT-T, or vice versa,
> which does not sound like a sane thing to do.

This is a perfectly valid use case. MOBIKE allows you roam your SAs
between different networks, NATed or not. In our implementation, we
switch UDP encapsulation strictly on and off depending on the new NAT
situation. However, other implementations don't [1].

It is a requirement for MOBIKE enabled peers to accept UDP encapsulated
packets in any case (see discussion [2]), and it is currently discussed
to add this requirement to the revised IKEv2 core standard [3]:

> o  Implementations MUST process received UDP-encapsulated ESP packets
>       even when no NAT was detected.

The fact that there is not NAT between peers is no guarantee that the
peer will not use UDP encapsulation.

I don't see any reason to drop ESP packets because of the used UDP
encapsulation mode. What's the point of doing so?

Martin

[1]https://lists.strongswan.org/pipermail/users/2008-December/002936.html
[2]http://www.machshav.com/pipermail/mobike/2006-September/001491.html
[3]http://tools.ietf.org/html/draft-ietf-ipsecme-ikev2bis-01#section-2.23



