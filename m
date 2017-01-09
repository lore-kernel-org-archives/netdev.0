From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Mon, 9 Jan 2017 23:56:41 +0100
Message-ID: <20170109225641.GB22820@lunn.ch>
References: <587410EF.5090607@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Kwok, WingMan" <w-kwok2@ti.com>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53579 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764260AbdAIW4n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 17:56:43 -0500
Content-Disposition: inline
In-Reply-To: <587410EF.5090607@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 05:38:39PM -0500, Murali Karicheri wrote:
> Hello Charles-Antoine, Andrew,
> 
> We have recently upgraded our kernel to v4.9 and started seeing an issue
> on our Keystone EVMs (K2E/L) that uses Marvel Phy 1510. The issue is that
> when we do a reboot command from the Linux console or do a SoC reset,
> the DHCP times out at U-Boot due to Phy auto negotiation failure. This works
> fine when the board is power cycled.

I've seen similar before. What version of kernel are you upgrading
from?

The problem i've had is that on shutdown/reboot, linux powers the PHYs
off. The uboot i have does not power them on again. Clearly a uboot
issue, it should not assume the PHYs are powered on.

I work around this with a uboot command:

mii write 1 0 0x3100

where the PHY is at address 1 on the bus. This writes to register 0,
and the import bit which needs setting to 0 is bit 11.

If mii read shows bit 11 is set, you know there uboot did not power up
the PHY.

    Andrew
