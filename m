From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next 0/7] Add netdev_printk and netif_printk
 macros
Date: Fri, 12 Feb 2010 20:12:16 -0800
Message-ID: <1266034336.14805.84.camel@Joe-Laptop>
References: <cover.1265751023.git.joe@perches.com>
	 <20100212.123129.163263355.davem@davemloft.net>
	 <20100212.131004.197405614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1951 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754736Ab0BMEMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 23:12:18 -0500
In-Reply-To: <20100212.131004.197405614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-12 at 13:10 -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 12 Feb 2010 12:31:29 -0800 (PST)
> > All applied to net-next-2.6, thanks!
> Hmmm, some build problems:
> 
> drivers/net/atl1e/atl1e_main.c: In function 'atl1e_vlan_rx_register':
> drivers/net/atl1e/atl1e_main.c:322: error: 'struct net_device' has no member named 'adapter'
> drivers/net/atl1e/atl1e_main.c:322: error: 'struct net_device' has no member named 'adapter'
> drivers/net/atl1e/atl1e_main.c: In function 'atl1e_restore_vlan':
> drivers/net/atl1e/atl1e_main.c:343: error: 'struct net_device' has no member named 'adapter'
> drivers/net/atl1e/atl1e_main.c:343: error: 'struct net_device' has no member named 'adapter'
> ...
> 
> Passing in a derference like "adapter->netdev" as an argument doesn't work with these macros
> end up giving us things like:
> 
> 	dev_driver_string((adapter->netdev)->adapter->netdev.parent)
> and
> 	dev_name((adapter->netdev)->adapter->netdev.parent)
> 
> The issue seems to be the netdev_dbg() define when DEBUG is not set and
> CONFIG_DYNAMIC_DEBUG is set.
> 
> It goes "(dev)->dev.parent" and CPP has fun with that.
> 
> I'll use a different name for the first macro argument to netdev_dbg() and see
> if that's enough to fix this.

Hi David.

Been out a couple of days.
I sent it as an RFC not meaning them to be applied.

It's actually the dev_name((dev)->dev. expansion.

I've redone these patches using (netdev) as the argument
to dev_name.

If you want to take the RFC patches, OK, but I could send
a patchset that compiles all cases cleanly.  Want that?

