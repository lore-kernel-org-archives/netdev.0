From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netfront for review
Date: Wed, 2 May 2007 13:51:27 +1000
Message-ID: <20070502035127.GA28090@gondor.apana.org.au>
References: <4637D672.5030706@goop.org> <1178077033.28659.173.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3946 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2992669AbXEBDvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 23:51:43 -0400
Content-Disposition: inline
In-Reply-To: <1178077033.28659.173.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2007 at 01:37:13PM +1000, Rusty Russell wrote:
>
> > +static int xennet_change_mtu(struct net_device *dev, int mtu)
> > +{
> > +	int max = xennet_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
> > +
> > +	if (mtu > max)
> > +		return -EINVAL;
> > +	dev->mtu = mtu;
> > +	return 0;
> > +}
> 
> This seems odd to me: just because a device does TSO should we really
> allow huge mtu settings?  Herbert?

Actually this has nothing to do with TSO/GSO.  This driver inherently
supports arbitrary MTUs that's only limited by our network stack.  If
the physical network device can't handle it you'll just get an ICMP
error back or fragmentation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
