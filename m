From: Stefan Rompf <stefan@loplof.de>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Thu, 6 Dec 2007 15:31:53 +0100
Message-ID: <200712061531.54107.stefan@loplof.de>
References: <200712061235.06025.stefan@loplof.de> <200712061330.20586.stefan@loplof.de> <20071206.055515.180308628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, simon@fire.lp0.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.189]:49933 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbXLFOaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:30:18 -0500
In-Reply-To: <20071206.055515.180308628.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 6. Dezember 2007 14:55 schrieb David Miller:

> You keep ignoring the fact that, as Herbert and I discussed, not
> blocking for IPSEC resolution will make some connect() cases fail that
> would otherwise not fail.
>
> There are two sides to this issue, and we need to consider them
> both.

as far as I've understood Herbert's patch, at least TCP connect can be fixed 
so that non blocking connect() will neither fail nor block, but just use the 
first or second retransmission of the SYN packet to complete the handshake 
after IPSEC is up. As this will fix the common breakage case, just do so and 
keep UDP sendmsg() etc for later.

You are looking at this issue too much from the kernel side. Admitted, this is 
a corner case, but therefore nobody cares if connection completion takes two 
SYNs and three seconds instead of one SYN and may be two seconds. But 
application developers and users will validly complain if their applications 
block unexpectedly for hours just because some random provider has a network 
outage and IPSEC cannot come up.

Stefan
