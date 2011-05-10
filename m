From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info
 data size
Date: Mon, 09 May 2011 20:58:28 -0700 (PDT)
Message-ID: <20110509.205828.104070242.davem@davemloft.net>
References: <20110509201705.409f6d39@nehalam>
	<1304999127.3050.40.camel@edumazet-laptop>
	<20110509205626.19dede92@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gregory.v.rose@intel.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755702Ab1EJD7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 23:59:00 -0400
In-Reply-To: <20110509205626.19dede92@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 9 May 2011 20:56:26 -0700

> I was hoping that the new interface dump would not need a pre-calculated
> size and could just incrementally add values. I was trying to use an
> analogy with route dumping. The current route dump does not precalculate
> size.

Stephen the problem here is that one netdevice being dumped is highly
variable because of the VF netlink attributes.

Routes have a fixed reasonably low upper bound in size, so we always are
able to fit one route in an SKB.

Netdevices, on the other hand, can have so many VFs that one netdevice
entry does not fit even in a single 8K allocated SKB.

That's the failure case this code is trying to fix.
