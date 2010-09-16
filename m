From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [E1000-devel] [PATCH] net: enable GRO by default for vlan
 devices
Date: Wed, 15 Sep 2010 23:21:25 -0700
Message-ID: <20100915232125.4430a421@nehalam>
References: <1284588203.2462.81.camel@edumazet-laptop>
	<1284589691.2462.85.camel@edumazet-laptop>
	<20100915181616.578fcd37@nehalam>
	<20100915.225146.35823170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bphilips@suse.de,
	e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48823 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079Ab0IPGV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Sep 2010 02:21:28 -0400
In-Reply-To: <20100915.225146.35823170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Sep 2010 22:51:46 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 15 Sep 2010 18:16:16 -0700
> 
> > On Thu, 16 Sep 2010 00:28:11 +0200
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> >> BTW, we have a similar problem for bonding ( GRO is disabled )
> >> 
> >> # ethtool -K bond0 gro off
> >> # ethtool -K bond0 gro on
> >> Cannot set device GRO settings: Invalid argument
> >> 
> >> Same for vlans on top of bond0
> > 
> > Bridge has same problem as well.
> 
> Looking this over it should be a simple matter of:
> 
> 1) Adding the generic get/set gro ethtool ops to bonding
>    and bridge device ops.
> 
> 2) Set NETIF_F_GRO in bond/bridge device flags
> 
> 3) Maybe some minor fiddling with netdev_increment_features
>    and the flag macros it uses?
> 
> Patches welcome :-)

I think it is more complex than that. GRO is tied to NAPI,
and bridge/bond don't use NAPI directly. They use netif_rx() for receiving
because layered drivers can't directly up call because of possible
issues with stack depth. 

To get GRO working for netif_rx case,
the logic in process_backlog would have to change.
But this queue is processing packets from multiple devices so
it is not clear if GRO could be used.


-- 
