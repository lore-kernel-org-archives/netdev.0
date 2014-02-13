From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 01/10] net: phy: add "internal" PHY mode
Date: Thu, 13 Feb 2014 15:34:09 -0500 (EST)
Message-ID: <20140213.153409.1193335923050383308.davem@davemloft.net>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
	<1392269395-23513-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cernekee@gmail.com,
	devicetree@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaBMUeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 15:34:11 -0500
In-Reply-To: <1392269395-23513-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 12 Feb 2014 21:29:46 -0800

> On some systems, the PHY can be internal, in the same package as the
> Ethernet MAC, and still be responding to a specific address on the MDIO
> bus, in that case, the Ethernet MAC might need to know about it to
> properly configure a port multiplexer to switch to an internal or
> external PHY. Add a new PHY interface mode for this and update the
> Device Tree of_get_phy_mode() function to look for it.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes since v1:
> - rebased against lastest net-next master branch

This is over-engineering.

The only thing that even uses this value is phy_is_internal(), and
the only user of phy_is_internal() is the generic PHY layer ethtool
operation for get-settings.

The PHY layer already has a place to indicate whether a PHY is
internal or not, overriding that using the PHY mode is trouble
waiting to happen.

Please, just provide some way to propagate this device tree property
into phy->is_internal.
