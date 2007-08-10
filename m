From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Share correct feature code between bridging and bonding
Date: Fri, 10 Aug 2007 15:48:17 -0700 (PDT)
Message-ID: <20070810.154817.04442540.davem@davemloft.net>
References: <20070809033601.GA16912@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53072
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753552AbXHJWsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:48:17 -0400
In-Reply-To: <20070809033601.GA16912@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 9 Aug 2007 11:36:01 +0800

> Hi Dave:
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

Applied, thanks a lot for fixing this bug Herbert!
