From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] atm: clip timer race
Date: Thu, 13 Apr 2006 22:45:34 +1000
Message-ID: <20060413124534.GA25333@gondor.apana.org.au>
References: <20060412105545.3b089dd8@localhost.localdomain> <E1FTjlM-00050V-00@gondolin.me.apana.org.au> <20060412124533.14e0c4ff@localhost.localdomain> <20060412200015.GA19878@gondor.apana.org.au> <20060412131527.71f42d58@localhost.localdomain> <20060412202551.GA20085@gondor.apana.org.au> <20060412145254.4dd21be6@localhost.localdomain> <20060412154214.1dd4117d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45842 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964913AbWDMMpz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 08:45:55 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060412154214.1dd4117d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2006 at 03:42:14PM -0700, Stephen Hemminger wrote:
> By inspection, the clip idle timer code is racy on SMP.
> Here is a safe version of timer management.
> Untested, I don't have ATM hardware.

Good catch Stephen.

> -	if (start_timer == 0)
> -		del_timer(&idle_timer);
> +	del_timer_sync(&idle_timer);

I don't think this is enough though since this timer is one of those
self-rescheduling timers.  You need to provide some sort of a flag
for it to stop scheduling itself and synchronise it properly.

Of course this is an existing bug but we might as well squash it
before we forget about it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
