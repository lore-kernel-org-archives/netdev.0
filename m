From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] llc2: Call llc_station_exit() on llc2_init()
 failure path
Date: Tue, 14 Aug 2012 16:52:23 -0700 (PDT)
Message-ID: <20120814.165223.953955272458502981.davem@davemloft.net>
References: <1344862120.824.139.camel@deadeye.wl.decadent.org.uk>
	<1344862243.824.141.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542Ab2HNXwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 19:52:24 -0400
In-Reply-To: <1344862243.824.141.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 13 Aug 2012 13:50:43 +0100

> Otherwise the station packet handler will remain registered even though
> the module is unloaded.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

This will cause section mismatch errors, you'll need to remove
the __exit tag from llc_station_exit() if you want to start
invoking it from llc2_init() which is __init.

I took care of this when applying this patch to 'net'.
