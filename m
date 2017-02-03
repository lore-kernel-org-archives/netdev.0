From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCHv2 net-next 01/16] dt-bindings: net: update Marvell PPv2
 binding for PPv2.2 support
Date: Fri, 3 Feb 2017 16:48:08 +0000
Message-ID: <20170203164808.GD27312@n2100.armlinux.org.uk>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <20170103201842.hdg2uzzesog2jund@rob-hp-laptop>
 <20170202175650.1fc06c2d@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Pawel Moll <pawel.moll@arm.com>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        netdev@vger.kernel.org, Hanna Hawa <hannah@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Kumar Gala <galak@codeaurora.org>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:55408 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbdBCQs1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:48:27 -0500
Content-Disposition: inline
In-Reply-To: <20170202175650.1fc06c2d@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 05:56:50PM +0100, Thomas Petazzoni wrote:
> For PPv2.2, we wanted to simplify a little bit the register mappings,
> and simply reflect the memory map of the SoC. In the SoC datasheet,
> there are two memory areas for the networking subsystem, which are the
> two areas reflected in:
> 
>         reg = <0x0 0x100000>,
>               <0x100000 0x80000>;
> 
> The per-port registers are inside the second register area. But by
> exposing the entire register area in the Device Tree binding, we allow
> improvements in the driver that need additional registers to be made
> without changing the Device Tree description of the device.

Are you sure that this makes sense?  You have the serdes block at
0x120000-0x125fff, which sits within that range, and that needs to
be configured for SATA and PCIe, so it's not strictly just a network
thing.

I know from my experimentation that disabling the "serdes" by clearing
the SD_EXTERNAL_CONFIG1_REG and SD_EXTERNAL_CONFIG0_REG for SATA
channels prevents SATA working.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
