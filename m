From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Mon, 03 Aug 2009 13:05:57 +0100
Message-ID: <1249301157.2893.11.camel@achroite>
References: <20090729073523.GA4515@gondor.apana.org.au>
	 <20090802.130704.133993421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mpm@selenic.com,
	netdev@vger.kernel.org, mcarlson@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42572 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754649AbZHCMGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 08:06:11 -0400
In-Reply-To: <20090802.130704.133993421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-08-02 at 13:07 -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 29 Jul 2009 15:35:23 +0800
> 
> > So if a driver is in the TX path, and a printk occurs, then a
> > recursive dead lock can occur if that driver tries to take the
> > xmit lock in its poll function to clean up descriptors.
> 
> My position has always been that such printk's are simply
> not allowed.  (check archives if you don't believe me :-)
>
> The locking is going to get rediculious if we start having
> to account for this.

I agree with that, but this does seem quite restrictive.  How can we be
sure that none of the kernel functions used by a driver's TX path (e.g.
kmalloc or DMA-mapping) will print debug or warning messages?  If such
guarantees exist, they do not seem to be documented.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

