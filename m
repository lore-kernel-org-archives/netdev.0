From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 12:59:19 -0700 (PDT)
Message-ID: <20090728.125919.146001472.davem@davemloft.net>
References: <20090728024813.GA23992@gondor.apana.org.au>
	<20090727.212107.161491585.davem@davemloft.net>
	<20090728071247.GA25611@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750722AbZG1T7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 15:59:12 -0400
In-Reply-To: <20090728071247.GA25611@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 28 Jul 2009 15:12:47 +0800

> However, in that case you'll now have two locks bouncing around
> instead of one and my guess would be that the cache overhead
> would offset any gain that is made from the parallel processing.

The premise is that there'd be only one.  The qdisc lock.

If the traffic is distributed, flow wise, the driver XMIT
lock would spread due to multiqueue.
