From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: Re: [PATCH v2] net/phy: micrel: Reenable interrupts during resume
Date: Fri, 31 Jul 2015 09:27:06 -0500
Message-ID: <20150731142706.GA11442@nathan3500-linux-VM>
References: <1438269348-8725-1-git-send-email-nathan.sullivan@ni.com>
 <20150730.100034.1983500409184401997.davem@davemloft.net>
 <20150730230905.GA9355@nathan3500-linux-VM>
 <20150731.002204.2044640569422262574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150731.002204.2044640569422262574.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 31, 2015 at 12:22:04AM -0700, David Miller wrote:
> From: Nathan Sullivan <nathan.sullivan@ni.com>
> Date: Thu, 30 Jul 2015 18:09:05 -0500
> 
> > On Thu, Jul 30, 2015 at 10:00:34AM -0700, David Miller wrote:
> >> From: Nathan Sullivan <nathan.sullivan@ni.com>
> >> Date: Thu, 30 Jul 2015 10:15:48 -0500
> >> 
> >> > Changes for V2: Actually make sure it compiles this time.
> >> 
> >> If V1 didn't compile, even for you, then I have a big problem.
> >> 
> >> And that problem is that you didn't test this change at all.
> > 
> > Sorry about that, I have tested it against 3.14, which is why I had
> > the older interrupt function in v1.  On HEAD, the phy no longer
> > suspends when ethernet goes down on our hardware - I'm still working
> > on figuring out why.  I'm also surprised no one noticed this behavior
> > before I did, but if the phy never goes into suspend you wouldn't.
> 
> I think you should sort out the PHY suspending issue before we move
> forward with this patch.

I believe I found the issue, we are using this PHY with cadence macb as
the MAC.  The driver currently turns off the management port in
macb_reset_hw, which we have stopped with a local change since our hardware
typically has multiple phys on one mdio bus.  That also prevents phy suspend
from working correctly, since the bus goes down before the phy state machine
can stop the phy.

In our local patch, we have macb_reset_hw keep the mdio bus on if it's on
already.  Does that sound like an acceptable fix to you?
