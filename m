From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Wed, 23 Mar 2016 19:50:06 +0100
Message-ID: <20160323185006.GL5250@lunn.ch>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, ujhelyi.m@gmail.com, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55637 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175AbcCWSuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 14:50:08 -0400
Content-Disposition: inline
In-Reply-To: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 06:51:37PM +0100, Vishal Thanki wrote:
> Hi all,
> 
> Based on suggestions from Andrew and Florian, I have made some changes
> to expose the ethernet PHY LEDs using kernel LED subsystem. The following
> ALPHA patchset introduces two new LED triggers:
> 
> 1) <phydev>-eth-phy-link:
> To monitor the PHY Link status
> 
> 2) <phydev>-eth-phy-activity:
> To monitor the PHY activity status. This trigger may still some more work
> because as of now it just takes decision to set the trigger based on
> PHY state machine and triggers the blink_set with delay_on and delay_off
> parameters set to 0.

My suggestion was that the hardware needs to control the LEDs. You
have software doing it. You might be able to do this with the PHY
state machine for link. But activity is never going to be accepted if
software control.

The LED trigger attached to an LED should be used to configure the
hardware to drive the LED as wanted.

The exception to this is when there is no trigger attached, and the
brightness can set the on/off state, if the hardware supports this.

	   Andrew
