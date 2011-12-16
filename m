From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: update mdiobus_alloc() to allocate extra
 private space
Date: Fri, 16 Dec 2011 15:32:54 -0500 (EST)
Message-ID: <20111216.153254.1998330487051662169.davem@davemloft.net>
References: <1323967895-5205-1-git-send-email-timur@freescale.com>
	<8ABCAC4C-1D11-41AD-AE46-96EB9D40588D@freescale.com>
	<4EEA2A61.8050302@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932590Ab1LPUeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:34:00 -0500
In-Reply-To: <4EEA2A61.8050302@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Thu, 15 Dec 2011 11:12:01 -0600

> Andy Fleming wrote:
>> Why? Doesn't this just obfuscate things a little, while providing no immediate benefit?
> 
> I see code like this frequently:
> 
> 	bus = mdiobus_alloc();
> 	if (bus == NULL)
> 		return -ENOMEM;
> 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> 	if (priv == NULL) {
> 		err = -ENOMEM;
> 		goto out_free;
> 	}
> 	bus->priv = priv;

Where "frequently", all of the mdiobus_alloc() call sites in your patch just
get translated to pass "0" for the private size.

Make the change how I suggested, where mdiobus_alloc() retains it's current
function signature and semantics.  Then you can edit drivers as needed rather
than from the beginning.
