From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Tue, 17 May 2011 09:45:38 +1000
Message-ID: <20110516234538.GA11832@gondor.apana.org.au>
References: <20110516121857.GA4495@gondor.apana.org.au> <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com> <20110516224658.GA11157@gondor.apana.org.au> <20110516.190615.2121423692228640268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mirqus@gmail.com, mst@redhat.com, shanwei@cn.fujitsu.com,
	mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59090 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623Ab1EPXpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 19:45:51 -0400
Content-Disposition: inline
In-Reply-To: <20110516.190615.2121423692228640268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 07:06:15PM -0400, David Miller wrote:
>
> Well the check has to exist somewhere.
> 
> Currently userspace can configure tun/tap into whatever set
> of offloads it likes.
> 
> We're warning when the user asks for something that needs to be
> corrected.  So the only thing you can suggest is to duplicate these
> changes in the tun/tap driver.
> 
> But if we do that, and error on bad combinations instead of fixing
> them up, we know from this discussion that existing virtualization
> setups and tools are going to stop working.

Yeah the tun driver is simply busted.  We should never have allowed
user-space to tweak the feature bits like this.  Instead they should
have gone through the ethtool interface like everyone else, or at
least use the same underlying calls as ethtool.

Actually, I think we can still do that, and apply the same rules
as ethtool with respect to automatically turning things on/off.

AFAICS the current set_offload in tun.c does not call anything
that verifies/fixes up the settings.  If you change the feature
bits after registering the tun device it may never get fixed up
at all.

Allowing an unprivileged user to tweak feature bits directly with
no verification is just wrong.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

