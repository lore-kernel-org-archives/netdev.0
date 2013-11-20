From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v1 0/7] net: phy: Ethernet PHY powerdown
 optimization
Date: Wed, 20 Nov 2013 15:36:42 -0500 (EST)
Message-ID: <20131120.153642.2045230991917379052.davem@davemloft.net>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Wed, 20 Nov 2013 21:21:46 +0100

> Ethernet PHYs consume a significant amount of power when link is detected.
> Especially, for embedded systems it can be easily 20-40% of total system
> power. Now, currently most likely all ethernet drivers leave PHYs powered
> on, even if the device is taken down. Also, some stupid boot loaders power
> on all PHYs available.
> 
> This RFC deals with saving power consumed by ethernet PHYs, that have no
> corresponding ethernet device driver or are attached to ethernet devices
> which are taken down by user request, i.e. ifconfig ethN down. Ports with
> no link, i.e. cable removed, are already quite good at power saving due to
> PHY internal link detection.

The idea is sound and the goal is of course valuable, but it brings up
a chronically reoccurring issue as of late.

You cannot reset the PHY or take it down without somehow retaining the
settings the PHY had when you bring it back up.

If I ifdown/ifup a device, my ethtool link configuration better be
retained.

This means the PHY layer must have a way to reprogram the device when
it is brought back up, with whatever settings the software state
things are there.
