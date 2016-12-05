From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ep93xx_eth: Do not crash unloading module
Date: Mon, 05 Dec 2016 15:36:02 -0500 (EST)
Message-ID: <20161205.153602.1770726597007697695.davem@davemloft.net>
References: <20161205032205.14127-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hsweeten@visionengravers.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752294AbcLEUgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 15:36:03 -0500
In-Reply-To: <20161205032205.14127-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun,  4 Dec 2016 19:22:05 -0800

> When we unload the ep93xx_eth, whether we have opened the network
> interface or not, we will either hit a kernel paging request error, or a
> simple NULL pointer de-reference because:
> 
> - if ep93xx_open has been called, we have created a valid DMA mapping
>   for ep->descs, when we call ep93xx_stop, we also call
>   ep93xx_free_buffers, ep->descs now has a stale value
> 
> - if ep93xx_open has not been called, we have a NULL pointer for
>   ep->descs, so performing any operation against that address just won't
>   work
> 
> Fix this by adding a NULL pointer check for ep->descs which means that
> ep93xx_free_buffers() was able to successfully tear down the descriptors
> and free the DMA cookie as well.
> 
> Fixes: 1d22e05df818 ("[PATCH] Cirrus Logic ep93xx ethernet driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
