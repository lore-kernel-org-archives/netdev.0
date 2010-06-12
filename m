From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 1/2] net: Enable 64-bit net device statistics on
 32-bit architectures
Date: Sat, 12 Jun 2010 15:54:54 -0700 (PDT)
Message-ID: <20100612.155454.108790680.davem@davemloft.net>
References: <1276017594.2185.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751997Ab0FLWyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jun 2010 18:54:43 -0400
In-Reply-To: <1276017594.2185.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 08 Jun 2010 18:19:54 +0100

> Use struct rtnl_link_stats64 as the statistics structure.
> 
> On 32-bit architectures, insert 32 bits of padding after/before each
> field of struct net_device_stats to make its layout compatible with
> struct rtnl_link_stats64.  Add an anonymous union in net_device; move
> stats into the union and add struct rtnl_link_stats64 stats64.
> 
> Add net_device_ops::ndo_get_stats64, implementations of which will
> return a pointer to struct rtnl_link_stats64.  Drivers that implement
> this operation must not update the structure asynchronously.
> 
> Change dev_get_stats() to call ndo_get_stats64 if available, and to
> return a pointer to struct rtnl_link_stats64.  Change callers of
> dev_get_stats() accordingly.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
