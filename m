From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc911x: Fix crash if loopback test fails
Date: Sun, 01 Nov 2015 12:05:53 -0500 (EST)
Message-ID: <20151101.120553.795381546235061779.davem@davemloft.net>
References: <1446101122-6440-1-git-send-email-p.fedin@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbKARFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 12:05:54 -0500
In-Reply-To: <1446101122-6440-1-git-send-email-p.fedin@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Thu, 29 Oct 2015 09:45:22 +0300

> On certain hardware in certain situations loopback test fails and the
> driver gets removed. During mdiobus_unregister() instance of PHY driver
> gets disposed. But by this time it has already been started using
> phy_connect_direct().
> 
> PHY driver uses DELAYED_WORK in order to maintain its state. Attempting
> to dispose the driver without calling phy_disconnect() causes deallocation
> of DELAYED_WORK being active. This shortly causes a bad crash in timer
> code.
> 
> The problem can be discovered by enabling CONFIG_DEBUG_OBJECTS_TIMERS and
> CONFIG_DEBUG_OBJECTS_FREE
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>

Applied, thanks.
