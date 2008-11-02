From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 01 Nov 2008 21:40:08 -0700 (PDT)
Message-ID: <20081101.214008.201420949.davem@davemloft.net>
References: <20081031.165144.86556444.davem@davemloft.net>
	<20081031165620.7322b0e5@extreme>
	<22495.1225498593@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, zbr@ioremap.net,
	ilpo.jarvinen@helsinki.fi, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	efault@gmx.de, akpm@linux-foundation.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbYKBEkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:40:33 -0400
In-Reply-To: <22495.1225498593@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 31 Oct 2008 17:16:33 -0700

> 	I suspect it could also be tucked away in skb_bond_should_drop,
> which is called both by the standard input path and the VLAN accelerated
> path to see if the packet should be tossed (e.g., it arrived on an
> inactive bonding slave).
> 
> 	Since last_rx is part of struct net_device, I don't think any
> additional bonding internals knowledge would be needed.  It could be
> arranged to only update last_rx for devices that are actually bonding
> slaves.
> 
> 	Just off the top of my head (haven't tested this), something
> like this:
 ...
> 
> 	That doesn't move the storage out of struct net_device, but it
> does stop the updates for devices that aren't bonding slaves.  It could
> probably be refined further to only update when the ARP monitor is
> running (the gizmo that uses last_rx).

I like this very much.

Jay can you give this a quick test by just trying this patch
and removing the ->last_rx setting in the driver you use for
your test?

Once you do that, I'll apply this to net-next-2.6 and do the
leg work to zap all of the ->last_rx updates from the entire tree.

Thanks!
