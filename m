From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 02 Jul 2012 01:36:26 -0700 (PDT)
Message-ID: <20120702.013626.13785263551119133.davem@davemloft.net>
References: <4FF153F0.8080707@mellanox.com>
	<CAG4TOxNyxP8FpzNdMZR3WMvFCQtEx_r3oLh6s7sZOcBnqN=6tA@mail.gmail.com>
	<4FF15BA2.5000104@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755343Ab2GBIg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 04:36:27 -0400
In-Reply-To: <4FF15BA2.5000104@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 2 Jul 2012 11:28:18 +0300

> On 7/2/2012 11:14 AM, Roland Dreier wrote:
>> What was wrong with Dave's initial suggestion of ethtool? All the
>> other steering stuff is configured that way, why not this hash?
> 
> Roland, as I wrote earlier on this thread --> [...] pointed out in the
> change-log, note that this policy is **global** to the HCA, that is
> effects all the Ethernet (and down the road, also when adding support
> for IPoIB flow-steering, under a config of card with one IB port and
> one Eth port) net-devices that relate to that mlx4 device instance.
> 
> In a system with (say) one card and two Ethernet ports, where for each
> port there's corresponding ethN interface, **both** mlx4_en
> net-devices use the same instance of struct mlx4_device, which means
> that if we let the user to set through ethtool the flow steering hash
> of ethN1 this will evetually change also the hash used for packets
> going to ethN2, or in other words, in mlx4 language this param belong
> to the mlx4_core module. In that respect, I was thinking on using
> sysfs as we do for the port link type and IB mtu, hope this makes
> things clearer, SB the relevant code, now with the global module param
> which can change to using per mlx4_core device sysfs.

I frankly don't care what your special unique situation is.

You cannot create chipset specific interfaces like module parms
and randomly named sysfs files as an interface to configure your
hardware.

Other chipsets will want the same thing or something similar.

So you must create a real generic interface that other chipsets
in similar situations can hook into as well.
