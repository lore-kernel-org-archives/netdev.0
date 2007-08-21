From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Share correct feature code between bridging and bonding
Date: Tue, 21 Aug 2007 00:07:41 -0700 (PDT)
Message-ID: <20070821.000741.115909144.davem@davemloft.net>
References: <20070809033601.GA16912@gondor.apana.org.au>
	<20070810.154817.04442540.davem@davemloft.net>
	<20070821062255.GA21799@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751280AbXHUHHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 03:07:42 -0400
In-Reply-To: <20070821062255.GA21799@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 21 Aug 2007 14:22:55 +0800

> Hi:
> 
> Here's the back-port for 2.6.22.
> 
> [NET]: Share correct feature code between bridging and bonding
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=8797 shows that the
> bonding driver may produce bogus combinations of the checksum
> flags and SG/TSO.
> 
> For example, if you bond devices with NETIF_F_HW_CSUM and
> NETIF_F_IP_CSUM you'll end up with a bonding device that
> has neither flag set.  If both have TSO then this produces
> an illegal combination.
> 
> The bridge device on the other hand has the correct code to
> deal with this.
> 
> In fact, the same code can be used for both.  So this patch
> moves that logic into net/core/dev.c and uses it for both
> bonding and bridging.
> 
> In the process I've made small adjustments such as only
> setting GSO_ROBUST if at least one constituent device
> supports it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I was about to send this off, but you beat me to it :-)

Acked-by: David S. Miller <davem@davemloft.net>
