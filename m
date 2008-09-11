From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Thu, 11 Sep 2008 04:47:17 -0700 (PDT)
Message-ID: <20080911.044717.265303740.davem@davemloft.net>
References: <20080911110035.GA22065@gondor.apana.org.au>
	<20080911.044255.245121628.davem@davemloft.net>
	<20080911114502.GA22698@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34632
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752321AbYIKLrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 07:47:24 -0400
In-Reply-To: <20080911114502.GA22698@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 11 Sep 2008 21:45:02 +1000

> On Thu, Sep 11, 2008 at 04:42:55AM -0700, David Miller wrote:
> > And we don't have the qdisc lock here, taking it is undesirable,
> > and if we do take it we have to transfer that lock down into
> > __qdisc_run() which means adjusting all the other __qdisc_run()
> > callers.
> 
> Last I checked qdisc_run did run under the root lock...

That certainly changes things :)

Ok, so implementing ->peek() is the first step in dealing
with this.
