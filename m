From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 V2] net: fix 64 bit counters on 32 bit
 arches
Date: Wed, 07 Jul 2010 14:36:45 -0700 (PDT)
Message-ID: <20100707.143645.135512197.davem@davemloft.net>
References: <1278353780.2877.620.camel@edumazet-laptop>
	<1278354682.2877.639.camel@edumazet-laptop>
	<1278360322.2466.90.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com, arnd@arndb.de,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756169Ab0GGVhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 17:37:13 -0400
In-Reply-To: <1278360322.2466.90.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Jul 2010 22:05:22 +0200

> [PATCH net-next-2.6 V2] net: fix 64 bit counters on 32 bit arches
> 
> There is a small possibility that a reader gets incorrect values on 32
> bit arches. SNMP applications could catch incorrect counters when a
> 32bit high part is changed by another stats consumer/provider.
> 
> One way to solve this is to add a rtnl_link_stats64 param to all 
> ndo_get_stats64() methods, and also add such a parameter to
> dev_get_stats().
> 
> Rule is that we are not allowed to use dev->stats64 as a temporary
> storage for 64bit stats, but a caller provided area (usually on stack)
> 
> Old drivers (only providing get_stats() method) need no changes.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks great, applied, thanks Eric.
