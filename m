From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Tue, 17 May 2011 08:18:45 +0300
Message-ID: <20110517051845.GA26414@redhat.com>
References: <20110516121857.GA4495@gondor.apana.org.au>
 <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
 <20110516224658.GA11157@gondor.apana.org.au>
 <20110516.190615.2121423692228640268.davem@davemloft.net>
 <20110516234538.GA11832@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mirqus@gmail.com,
	shanwei@cn.fujitsu.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309Ab1EQFSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 01:18:50 -0400
Content-Disposition: inline
In-Reply-To: <20110516234538.GA11832@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 09:45:38AM +1000, Herbert Xu wrote:
> On Mon, May 16, 2011 at 07:06:15PM -0400, David Miller wrote:
> >
> > Well the check has to exist somewhere.
> > 
> > Currently userspace can configure tun/tap into whatever set
> > of offloads it likes.
> > 
> > We're warning when the user asks for something that needs to be
> > corrected.  So the only thing you can suggest is to duplicate these
> > changes in the tun/tap driver.
> > 
> > But if we do that, and error on bad combinations instead of fixing
> > them up, we know from this discussion that existing virtualization
> > setups and tools are going to stop working.
> 
> Yeah the tun driver is simply busted.  We should never have allowed
> user-space to tweak the feature bits like this.  Instead they should
> have gone through the ethtool interface like everyone else, or at
> least use the same underlying calls as ethtool.
> 
> Actually, I think we can still do that, and apply the same rules
> as ethtool with respect to automatically turning things on/off.
> 
> AFAICS the current set_offload in tun.c does not call anything
> that verifies/fixes up the settings.  If you change the feature
> bits after registering the tun device it may never get fixed up
> at all.

Hmm, we get the warnings about bits dropped on each set_offload
call:
	netdev_update_features is called,
	that calls netdev_fix_features

No?

> Allowing an unprivileged user to tweak feature bits directly with
> no verification is just wrong.
> 
> Cheers,

But we do verify bits, and only allow the user
to tweak these ones:

#define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO|
\
                          NETIF_F_TSO6|NETIF_F_UFO)

No?

> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
