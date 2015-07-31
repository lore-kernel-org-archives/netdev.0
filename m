From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/phy: micrel: Reenable interrupts during resume
Date: Fri, 31 Jul 2015 13:21:29 -0700 (PDT)
Message-ID: <20150731.132129.1623811034601507745.davem@davemloft.net>
References: <20150730230905.GA9355@nathan3500-linux-VM>
	<20150731.002204.2044640569422262574.davem@davemloft.net>
	<20150731142706.GA11442@nathan3500-linux-VM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nathan.sullivan@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150731142706.GA11442@nathan3500-linux-VM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>
Date: Fri, 31 Jul 2015 09:27:06 -0500

> I believe I found the issue, we are using this PHY with cadence macb as
> the MAC.  The driver currently turns off the management port in
> macb_reset_hw, which we have stopped with a local change since our hardware
> typically has multiple phys on one mdio bus.  That also prevents phy suspend
> from working correctly, since the bus goes down before the phy state machine
> can stop the phy.
> 
> In our local patch, we have macb_reset_hw keep the mdio bus on if it's on
> already.  Does that sound like an acceptable fix to you?

Then you don't need this patch at all if your hardware configuration
in question will not suspend the PHY device.

Can you see how rediculous this situation looks to me?

You can't even test this change on the hardware you are using.
