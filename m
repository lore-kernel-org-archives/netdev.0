From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Remove notifier block from chain when register_netdevice_notifier fails
Date: Wed, 14 Nov 2007 21:37:17 +0800
Message-ID: <20071114133717.GA14746@gondor.apana.org.au>
References: <473AE523.70501@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2676 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753650AbXKNNhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 08:37:20 -0500
Content-Disposition: inline
In-Reply-To: <473AE523.70501@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 03:08:03PM +0300, Pavel Emelyanov wrote:
> Commit fcc5a03ac42564e9e255c1134dda47442289e466 makes the
> register_netdevice_notifier() handle the error from the
> NETDEV_REGISTER event, sent to the registering block. 
> 
> The bad news is that in this case the notifier block is 
> not removed from the list, but the error is returned to the 
> caller. In case the caller is in module init function and 
> handles this error this can abort the module loading. The
> notifier block will be then removed from the kernel, but 
> will be left in the list. Oops :(
> 
> I think that the notifier block should be removed from the
> chain in case of error, regardless whether this error is 
> handled by the caller or not. In the worst case (the error 
> is _not_ handled) module will not receive the events any 
> longer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Good catch.  Thanks Pavel!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
