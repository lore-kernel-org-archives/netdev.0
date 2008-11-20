From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] mv643xx_eth: implement ->set_rx_mode()
Date: Thu, 20 Nov 2008 03:59:31 -0800 (PST)
Message-ID: <20081120.035931.187406968.davem@davemloft.net>
References: <20081118222947.GV5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42752
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754756AbYKTL7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 06:59:31 -0500
In-Reply-To: <20081118222947.GV5006@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 18 Nov 2008 23:29:56 +0100

> Currently, if multiple unicast addresses are programmed into a
> mv643xx_eth interface, the core networking will resort to enabling
> promiscuous mode on the interface, as mv643xx_eth does not implement
> ->set_rx_mode().
> 
> This patch switches mv643xx_eth over from ->set_multicast_list()
> to ->set_rx_mode(), and implements support for secondary unicast
> addresses.  The hardware can handle multiple unicast addresses as
> long as their first 11 nibbles are the same (i.e. are of the form
> xx:xx:xx:xx:xx:xy where the x part is the same for all addresses), so
> if that is the case, we use that mode.  If it's not the case, we enable
> unicast promiscuous mode in the hardware, which is slightly better than
> enabling promiscuous mode for multicasts as well, which is what would
> happen before.
> 
> While we are at it, change the programming sequence so that we
> don't clear all filter bits first, so we don't lose all incoming
> packets while the filter is being reprogrammed.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied.
