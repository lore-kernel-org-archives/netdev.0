From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Send ICMPv6 RSes only when RAs are accepted
Date: Fri, 16 Sep 2011 17:15:03 -0400 (EDT)
Message-ID: <20110916.171503.42153974977438913.davem@davemloft.net>
References: <201108291209.p7TC9KkD002967@wrath.fud.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tore@fud.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab1IPVQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 17:16:11 -0400
In-Reply-To: <201108291209.p7TC9KkD002967@wrath.fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tore Anderson <tore@fud.no>
Date: Mon, 29 Aug 2011 14:08:33 +0200

> The change also makes "Hybrid Router" forwarding mode ("forwarding"
> sysctl set to 2) redundant, as the only thing that distinguished it from
> the standard Router mode (forwarding=1) was that RSes was being sent. It
> has therefore been removed.

You're not removing "accept_ra==2", it's still there in the test:

> -	if ((ifp->idev->cnf.forwarding == 0 ||
> -	     ifp->idev->cnf.forwarding == 2) &&
> +	if (((ifp->idev->cnf.accept_ra == 1 && !ifp->idev->cnf.forwarding) ||
> +	     ifp->idev->cnf.accept_ra == 2) &&

And it does provide it's own unique behavior compared to
"accept_ra==1".
