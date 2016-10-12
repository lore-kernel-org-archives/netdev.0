From: Kyle Roeschley <kyle.roeschley@ni.com>
Subject: Re: [RFC] net: phy: smsc: Disable auto-negotiation on startup
Date: Wed, 12 Oct 2016 10:05:33 -0500
Message-ID: <20161012150533.dctakcjczclk2mml@senary>
References: <20161010174123.21436-1-kyle.roeschley@ni.com>
 <0c2488d0-45f5-1ab7-bfa5-f19ae687a90f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0c2488d0-45f5-1ab7-bfa5-f19ae687a90f@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2016 at 02:13:06AM -0700, Florian Fainelli wrote:
> On 10/10/2016 10:41 AM, Kyle Roeschley wrote:
> > Because the SMSC PHY completes auto-negotiation before the driver is
> > ready to handle interrupts, the PHY state machine never realizes that we
> > have a link. Clear the ANENABLE bit on initialization, which lets
> > genphy_config_aneg do its thing when that code is hit later.
> > 
> > While this patch does fix the problem we see (no link on boot without
> > re-plugging the cable), it seems like the generic PHY code should be
> > able to handle auto-negotiation completing before interrupts are
> > enabled. Submitted as an RFC in the hopes that someone has an idea as to
> > how that could be done.
> > 
> > This fix is copied from commit 99f81afc139c ("phy: micrel: Disable auto
> > negotiation on startup").
> 
> Do you mind trying:
> 
> https://www.spinics.net/lists/netdev/msg397857.html
> 
> and see if you do get link interrupts without your patch applied? Thanks!

Yep, that fixes it. I figured there was some state machine issue I was missing.
Thanks very much!

> -- 
> Florian

-- 
Kyle Roeschley
Software Engineer
National Instruments
