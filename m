From: David Miller <davem@davemloft.net>
Subject: Re: linkwatch bustage in git-net
Date: Wed, 09 May 2007 00:18:14 -0700 (PDT)
Message-ID: <20070509.001814.116354599.davem@davemloft.net>
References: <20070509054558.GA1184@gondor.apana.org.au>
	<20070508231143.fcae61c7.akpm@linux-foundation.org>
	<20070509071614.GA2138@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755524AbXEIHSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 03:18:13 -0400
In-Reply-To: <20070509071614.GA2138@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 9 May 2007 17:16:15 +1000

> The real problem here is a combination of factors.  First of all e100
> does a netif_carrier_off in its open routine *before* the first call
> to dev_activate.  This when combined with the wrap-around bug causes
> an infinitely delayed event for your NIC to be installed.

I noticed that behavior of e100 too.

> [NET] link_watch: Always schedule urgent events
> 
> Urgent events may be delayed if we already have a non-urgent event
> queued for that device.  This patch changes this by making sure that
> an urgent event is always looked at immediately.
> 
> I've replaced the LW_RUNNING flag by LW_URGENT since whether work
> is scheduled is already kept track by the work queue system.
> 
> The only complication is that we have to provide some exclusion for
> the setting linkwatch_nextevent which is available in the actual
> work function.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for working this out, applied and pushed to net-2.6.git
