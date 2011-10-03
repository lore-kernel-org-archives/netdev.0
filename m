From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xen-netback: correctly restart Tx after a VM
 restore/migrate
Date: Mon, 03 Oct 2011 14:16:03 -0400 (EDT)
Message-ID: <20111003.141603.369934124561797426.davem@davemloft.net>
References: <1317400671-21236-1-git-send-email-david.vrabel@citrix.com>
	<1317401105.26672.319.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932369Ab1JCSQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 14:16:15 -0400
In-Reply-To: <1317401105.26672.319.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Fri, 30 Sep 2011 17:45:05 +0100

> On Fri, 2011-09-30 at 17:37 +0100, David Vrabel wrote:
>> If a VM is saved and restored (or migrated) the netback driver will no
>> longer process any Tx packets from the frontend.  xenvif_up() does not
>> schedule the processing of any pending Tx requests from the front end
>> because the carrier is off.  Without this initial kick the frontend
>> just adds Tx requests to the ring without raising an event (until the
>> ring is full).
>> 
>> This was caused by 47103041e91794acdbc6165da0ae288d844c820b (net:
>> xen-netback: convert to hw_features) which reordered the calls to
>> xenvif_up() and netif_carrier_on() in xenvif_connect().
> 
> Ah, so the bit of that patch which moved "netif_carrier_on(vif->dev);"
> should have actually moved the entire block
>  	netif_carrier_on(vif->dev);
> 	if (netif_running(vif->dev))
> 		xenvif_up(vif);
> 
> Since it it is logically a single thing. Make sense. Thanks!
> 
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied, thanks.
