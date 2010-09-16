From: David Miller <davem@davemloft.net>
Subject: Re: [E1000-devel] [PATCH] net: enable GRO by default for vlan
 devices
Date: Wed, 15 Sep 2010 22:51:46 -0700 (PDT)
Message-ID: <20100915.225146.35823170.davem@davemloft.net>
References: <1284588203.2462.81.camel@edumazet-laptop>
	<1284589691.2462.85.camel@edumazet-laptop>
	<20100915181616.578fcd37@nehalam>
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
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49812
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750714Ab0IPFv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 01:51:28 -0400
In-Reply-To: <20100915181616.578fcd37@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 15 Sep 2010 18:16:16 -0700

> On Thu, 16 Sep 2010 00:28:11 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> BTW, we have a similar problem for bonding ( GRO is disabled )
>> 
>> # ethtool -K bond0 gro off
>> # ethtool -K bond0 gro on
>> Cannot set device GRO settings: Invalid argument
>> 
>> Same for vlans on top of bond0
> 
> Bridge has same problem as well.

Looking this over it should be a simple matter of:

1) Adding the generic get/set gro ethtool ops to bonding
   and bridge device ops.

2) Set NETIF_F_GRO in bond/bridge device flags

3) Maybe some minor fiddling with netdev_increment_features
   and the flag macros it uses?

Patches welcome :-)
