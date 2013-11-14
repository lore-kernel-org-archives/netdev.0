From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: phylib: add adjust_state callback to phy
 device
Date: Thu, 14 Nov 2013 16:32:07 -0500 (EST)
Message-ID: <20131114.163207.230147902479371528.davem@davemloft.net>
References: <1384376870-7810-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marek.belisko@gmail.com,
	ujhelyi.m@gmail.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766Ab3KNVcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:32:09 -0500
In-Reply-To: <1384376870-7810-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Wed, 13 Nov 2013 22:07:49 +0100

> Allow phy drivers to take action when the core does its link adjustment.
> No change for drivers that do not implement this callback.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

So you're using this to reset the entire PHY via the reset bit in the
BMCR register when the link goes down.

But this is going to break things.

If the phy library previously programmed a non-autonegotiated static
link configuration into the BMCR register, your reset is going to
undo that.

Now the configuration phylib thinks the chip has and the one it
acutally does is out of sync.

I'm not applying these patches, sorry.
