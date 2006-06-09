From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable vs netif_stop_queue (possible races?)
Date: Fri, 09 Jun 2006 14:41:52 +1000
Message-ID: <E1FoYoi-0001gg-00@gondolin.me.apana.org.au>
References: <4488AF3D.2040601@gentoo.org>
Cc: netdev@vger.kernel.org, david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35598 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965153AbWFIEmL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 00:42:11 -0400
To: dsd@gentoo.org (Daniel Drake)
In-Reply-To: <4488AF3D.2040601@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake <dsd@gentoo.org> wrote:
> 
> More specifically, we're talking about drivers/usb/net/usbnet.c and the 
> usbnet_disconnect() function.  The race I am highlighting is that 
> usbnet's hard_start_xmit handler (usbnet_start_xmit) may be running when 
> the disconnect happens.
> 
> Is this a possible scenario?

It should be safe, if only because of the synchronize_net that occurs
before a netdev can be freed.

However, there is definitely room for clean-ups.  In particular, LLTX
drivers have changed the meaning of xmit_lock so things like dev_deactivate
no longer carries the same power they used to.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
