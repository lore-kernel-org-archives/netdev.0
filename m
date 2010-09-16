From: David Miller <davem@davemloft.net>
Subject: Re: [E1000-devel] [PATCH] net: enable GRO by default for vlan
 devices
Date: Wed, 15 Sep 2010 23:38:51 -0700 (PDT)
Message-ID: <20100915.233851.85414928.davem@davemloft.net>
References: <20100915181616.578fcd37@nehalam>
	<20100915.225146.35823170.davem@davemloft.net>
	<20100915232125.4430a421@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bphilips@suse.de,
	e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37186
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752361Ab0IPGic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 02:38:32 -0400
In-Reply-To: <20100915232125.4430a421@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 15 Sep 2010 23:21:25 -0700

> I think it is more complex than that. GRO is tied to NAPI,
> and bridge/bond don't use NAPI directly. They use netif_rx() for receiving
> because layered drivers can't directly up call because of possible
> issues with stack depth. 
> 
> To get GRO working for netif_rx case,
> the logic in process_backlog would have to change.
> But this queue is processing packets from multiple devices so
> it is not clear if GRO could be used.

Bonding's un-layering on RX is done in the normal netif_receive_skb()
control flow.

And bridging only uses netif_rx for multicast replication.
