From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: RPS vs. hard-irq-context netif_rx()
Date: Fri, 30 Jul 2010 15:21:55 +0200
Message-ID: <1280496115.3710.20.camel@jlt3.sipsolutions.net>
References: <1280495027.3710.13.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:56069 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756650Ab0G3NUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 09:20:35 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <johannes@sipsolutions.net>)
	id 1OepVo-0002KR-5v
	for netdev@vger.kernel.org; Fri, 30 Jul 2010 15:20:32 +0200
In-Reply-To: <1280495027.3710.13.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-07-30 at 15:03 +0200, Johannes Berg wrote:

> The reason seems to be that
>  * RCU_TREE uses local_bh_disable/enable
>  * CONFIG_RPS uses RCU within netif_rx()
>  * the driver I'm using calls netif_rx() within the irq context
> 
> So .. where's the bug? I'd point to CONFIG_RPS since it's newest.

Disabling RPS gives me the same result due to netpoll since

commit de85d99eb7b595f6751550184b94c1e2f74a828b
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Jun 10 16:12:44 2010 +0000

    netpoll: Fix RCU usage


Disabling netpoll as well gets me a warning-free boot, but I suspect
that's not really what it should be like...

johannes

