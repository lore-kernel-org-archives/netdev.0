From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: Do not set IF_READY if device is down
Date: Tue, 27 Mar 2007 14:33:24 -0700 (PDT)
Message-ID: <20070327.143324.58455258.davem@davemloft.net>
References: <200703080359.l283xo6S012573@hera.kernel.org>
	<1175003838.3277.41.camel@pmac.infradead.org>
	<20070327213032.GA30935@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965059AbXC0Vd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:33:26 -0400
In-Reply-To: <20070327213032.GA30935@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 28 Mar 2007 07:30:32 +1000

> On Tue, Mar 27, 2007 at 02:57:18PM +0100, David Woodhouse wrote:
> >
> > >     [IPV6]: Do not set IF_READY if device is down
> > >     
> > >     Now that we add the IPv6 device at registration time we don't need
> > >     to set IF_READY in ipv6_add_dev anymore because we will always get
> > >     a NETDEV_UP event later on should the device ever become ready.
> > >     
> > >     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > This commit seems to have broken NetworkManager, which removes the
> > link-local IPv6 address from each wireless interface while it's only
> > intending to use it for scanning, then adds it back when it actually
> > wants to _use_ the interface in question.
> 
> Sorry, that patch is indeed broken.  We do need to set IF_READY in
> the case where all addresses were deleted (including the link-local)
> and then recreated.  The IPv6 device will be destroyed and recreated
> too in that case.
> 
> [IPV6]: Set IF_READY if the device is up and has carrier
> 
> We still need to set the IF_READY flag in ipv6_add_dev for the case
> where all addresses (including the link-local) are deleted and then
> recreated.  In that case the IPv6 device too will be destroyed and
> then recreated.
> 
> In order to prevent the original problem, we simply ensure that
> the device is up before setting IF_READY.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

I'll make sure to push this to the relevant -stable places.
