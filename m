From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/davinci: do not use all descriptors for tx packets
Date: Tue, 03 Jan 2012 13:51:41 -0500 (EST)
Message-ID: <20120103.135141.1199352202815384466.davem@davemloft.net>
References: <1325604467-15122-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anantgole@ti.com, srk@ti.com
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab2ACSwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 13:52:49 -0500
In-Reply-To: <1325604467-15122-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Tue,  3 Jan 2012 16:27:47 +0100

> The driver uses a shared pool for both rx and tx descriptors.
> During open it queues fixed number of 128 descriptors for receive
> packets. For each received packet it tries to queue another
> descriptor. If this fails the descriptor is lost for rx.
> The driver has no limitation on tx descriptors to use, so it
> can happen during a nmap / ping -f attack that the driver
> allocates all descriptors for tx and looses all rx descriptors.
> The driver stops working then.
> To fix this limit the number of tx descriptors used to half of
> the descriptors available, the rx path uses the other half.
> 
> Tested on a custom board using nmap / ping -f to the board from
> two different hosts.
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Applied to net-next, thanks.

Well, at this point there is not logical reason to have a shared
descriptor pool unless the hardware requires it.  Does it?
