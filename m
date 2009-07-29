From: Matt Mackall <mpm@selenic.com>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Wed, 29 Jul 2009 14:07:58 -0500
Message-ID: <1248894478.4545.2822.camel@calx>
References: <20090729073523.GA4515@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:45280 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754081AbZG2TI0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2009 15:08:26 -0400
In-Reply-To: <20090729073523.GA4515@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-29 at 15:35 +0800, Herbert Xu wrote:
> Hi:
> 
> While working on TX mitigiation, I noticed that while netpoll
> takes care to avoid recursive dead locks on the NAPI path, it
> has no protection against the TX path when calling the poll
> function.
> 
> So if a driver is in the TX path, and a printk occurs, then a
> recursive dead lock can occur if that driver tries to take the
> xmit lock in its poll function to clean up descriptors.
> 
> Fortunately not a lot of drivers do this but at least some are
> vulnerable to it, e.g., tg3.
> 
> So we need to make it very clear that the poll function must
> not take any locks or they must use try_lock if the driver is
> to support netpoll.

What do you propose?

-- 
http://selenic.com : development and support for Mercurial and Linux


