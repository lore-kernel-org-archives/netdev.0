From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 07 Oct 2008 15:50:39 -0700 (PDT)
Message-ID: <20081007.155039.199136099.davem@davemloft.net>
References: <20080929175421.722037051@theryb.frec.bull.fr>
	<E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753390AbYJGWvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 18:51:04 -0400
In-Reply-To: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 05 Oct 2008 12:26:21 +0800

> net: Fix netdev_run_todo dead-lock
> 
> Benjamin Thery tracked down a bug that explains many instances
> of the error
> 
> unregister_netdevice: waiting for %s to become free. Usage count = %d
> 
> It turns out that netdev_run_todo can dead-lock with itself if
> a second instance of it is run in a thread that will then free
> a reference to the device waited on by the first instance.
> 
> The problem is really quite silly.  We were trying to create
> parallelism where none was required.  As netdev_run_todo always
> follows a RTNL section, and that todo tasks can only be added
> with the RTNL held, by definition you should only need to wait
> for the very ones that you've added and be done with it.
> 
> There is no need for a second mutex or spinlock.
> 
> This is exactly what the following patch does.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Ok, this looks safe.  I've applied this to net-2.6, thanks!
