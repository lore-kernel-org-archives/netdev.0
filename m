From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: fix unicast address filter corruption on
 mtu change
Date: Fri, 13 Mar 2009 15:48:13 -0700 (PDT)
Message-ID: <20090313.154813.05867923.davem@davemloft.net>
References: <20090310082248.GF4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753306AbZCMWs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:48:27 -0400
In-Reply-To: <20090310082248.GF4738@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 10 Mar 2009 09:22:48 +0100

> When mv643xx_eth_open() is called to up an interface, port_start()
> will first re-program the unicast address filter, and then
> re-initialise the PORT_CONFIG register, but that will disable unicast
> promiscuous mode if it was enabled by the unicast address filter setup.
> 
> This isn't a problem on ifconfig up, as ->set_rx_mode() will be called
> shortly afterwards which will program the filters again, but it does
> trigger when changing the MTU, which calls mv643xx_eth_stop() and then
> mv643xx_eth_open() by hand to repopulate the receive rings with skbuffs
> of the new size.
> 
> Swap the initialisation of the PORT_START register and the call to
> the unicast filter setup function to fix this.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied, thanks Lennert!
