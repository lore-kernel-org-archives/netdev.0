From: David Miller <davem@davemloft.net>
Subject: Re: ipcomp regression in 2.6.24
Date: Tue, 29 Jan 2008 21:12:27 -0800 (PST)
Message-ID: <20080129.211227.160323820.davem@davemloft.net>
References: <BAY103-DAV76D55A34FB3E0924FF49AB2350@phx.gbl>
	<E1JK3QD-0006hM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pupilla@hotmail.com, Daniel.Beschorner@facton.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750809AbYA3FMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 00:12:09 -0500
In-Reply-To: <E1JK3QD-0006hM-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 30 Jan 2008 14:15:33 +1100

> Marco Berizzi <pupilla@hotmail.com> wrote:
> >
> >> > With 2.6.24 IPSEC/ESP tunnels to older kernels establish fine, data
> >> > flows in both directions, but no data comes out of the tunnel.
> >> > Needed to disable ipcomp.
> > 
> > Same problem here: linux 2.6.24 driven by openswan 2.4.11
> > on Slackware 11.0
> 
> My bad.  This patch should fix it.
> 
> [IPCOMP]: Fetch nexthdr before ipch is destroyed
> 
> When I moved the nexthdr setting out of IPComp I accidently moved
> the reading of ipch->nexthdr after the decompression.  Unfortunately
> this means that we'd be reading from a stale ipch pointer which
> doesn't work very well.
> 
> This patch moves the reading up so that we get the correct nexthdr
> value.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and queued for -stable, thanks!
