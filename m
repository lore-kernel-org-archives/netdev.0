From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: RFC: blueprint for proxy PHY module
Date: Thu, 25 Feb 2016 16:24:33 +0100
Message-ID: <20160225152433.GA7681@lunn.ch>
References: <1456406760.28260.6@smtp.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pavol Kor?ek <ikorcek@fit.vutbr.cz>,
	Martin Strba?ka <martin.strbacka@nic.cz>
To: Tomas Hlavacek <tmshlvck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42788 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760651AbcBYPYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 10:24:37 -0500
Content-Disposition: inline
In-Reply-To: <1456406760.28260.6@smtp.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 02:26:00PM +0100, Tomas Hlavacek wrote:
> Hello!
> 
> We have a board with a MAC in SoC that has SGMII connected through a
> signal switch to either 10/100/1000 wired PHY or to a SFP cage. The
> signal switch is set to pass signal to the wired PHY by default.
> When the MOD-DEF0 pin from SFP cage is low (which acts as a
> transceiver-present signal) the wired PHY is being disconnected and
> the SGMII is passed to the SFP cage. We also have the signal
> connected to a GPIO input, so we can detect the SFP presence from
> software. And there is always-connected MDIO to the wired PHY.
> 
> Now I use two different DTBs for testing purposes, one has a
> configuration for the wired PHY and another one uses fixed-link for
> SFP. And I have to reboot in order to switch from one to another.
> 
> My idea is to create a "proxy PHY" module that would take state from
> one of two (or more) underlying PHYs and pass it to the NIC driver.
> The selection of the active PHY would come from userspace. (There
> will be a board-specific
> daemon that would react to the GPIO change and set the proper PHY
> accordingly.) Question is how to connect the userspace? I think that
> corresponding file in /sys would do the job, but I am not sure
> whether it is the proper way of doing that. (?)
> 
> What do you think about it?

Hi Tomas

Have you looked at Russell Kings phylink patchset?

https://lwn.net/Articles/667055/

	Andrew
