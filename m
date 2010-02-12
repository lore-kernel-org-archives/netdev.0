From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/7] Add netdev_printk and netif_printk
 macros
Date: Fri, 12 Feb 2010 13:10:04 -0800 (PST)
Message-ID: <20100212.131004.197405614.davem@davemloft.net>
References: <cover.1265751023.git.joe@perches.com>
	<20100212.123129.163263355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40016
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752032Ab0BLVJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 16:09:52 -0500
In-Reply-To: <20100212.123129.163263355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 12 Feb 2010 12:31:29 -0800 (PST)

> All applied to net-next-2.6, thanks!

Hmmm, some build problems:

drivers/net/atl1e/atl1e_main.c: In function 'atl1e_vlan_rx_register':
drivers/net/atl1e/atl1e_main.c:322: error: 'struct net_device' has no member named 'adapter'
drivers/net/atl1e/atl1e_main.c:322: error: 'struct net_device' has no member named 'adapter'
drivers/net/atl1e/atl1e_main.c: In function 'atl1e_restore_vlan':
drivers/net/atl1e/atl1e_main.c:343: error: 'struct net_device' has no member named 'adapter'
drivers/net/atl1e/atl1e_main.c:343: error: 'struct net_device' has no member named 'adapter'
...

Passing in a derference like "adapter->netdev" as an argument doesn't work with these macros
end up giving us things like:

	dev_driver_string((adapter->netdev)->adapter->netdev.parent)

and

	dev_name((adapter->netdev)->adapter->netdev.parent)

The issue seems to be the netdev_dbg() define when DEBUG is not set and
CONFIG_DYNAMIC_DEBUG is set.

It goes "(dev)->dev.parent" and CPP has fun with that.

I'll use a different name for the first macro argument to netdev_dbg() and see
if that's enough to fix this.
