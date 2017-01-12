From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: Correct method for initializing Pause and Asymmetrical Pause
 support in phy drivers
Date: Thu, 12 Jan 2017 16:52:38 +0100
Message-ID: <68c58b10-1458-636e-a4a6-686a17ba743b@neratec.com>
References: <CAMqDo0XxvtjD+uJQeHJuSyN71zEEa5AB9YE1CUYK8wq2NGeAbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>
To: Marc Bertola <marc.bertola@prolucid.ca>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:12640 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750799AbdALPxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 10:53:09 -0500
In-Reply-To: <CAMqDo0XxvtjD+uJQeHJuSyN71zEEa5AB9YE1CUYK8wq2NGeAbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 04:21 PM, Marc Bertola wrote:
> Hello netdev list,
> 
> I am currently investigating a problem related to Ethernet
> auto-negotiation of Pause and Asymmetrical Pause capabilities.
> 
> TL;DR: I am using a Picozed system-on-module with a Xilinx Gigabit
> Ethernet MAC and a Marvell PHY. It does not appear to be advertising
> support for Pause and Asym Pause, which seems strange to me given that
> this is relatively recent hardware. I suspect that may be due to a
> problem in the way phydev->supported is initialized in
> drivers/net/phy/marvell.c.
> 
> I am trying to confirm what the proper method is to initialize
> phydev->supported such that it advertises SUPPORTED_Pause and
> SUPPORTED_Asym_Pause.  Adding these flags to (phy_driver).features
> seems to work, but I would like to confirm with people who are more
> knowledgeable than me in this regard.
> [...]

This was discussed only recently and iirc consensus was:
* flow control is an ETH property, PHY is only forwarding the info
* => therefore (Asym)Pause flags are to be set by ETH driver, not by PHY

For reference, Timur Tabi cleaned up the PHY drivers around two months ago in [1].


Cheers,
Zefir


[1] https://www.spinics.net/lists/netdev/msg403806.html
