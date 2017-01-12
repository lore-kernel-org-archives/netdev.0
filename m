From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Thu, 12 Jan 2017 22:31:44 +0000
Message-ID: <20170112223144.GN14217@n2100.armlinux.org.uk>
References: <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
 <20170111222758.GG13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AE5@DFLE11.ent.ti.com>
 <20170111225948.GH13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354B2B@DFLE11.ent.ti.com>
 <20170111232200.GI13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354B66@DFLE11.ent.ti.com>
 <20170112010658.GA25391@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354EB0@DFLE11.ent.ti.com>
 <20170112214941.GE10203@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kwok, WingMan" <w-kwok2@ti.com>,
        "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:35388 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdALWbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 17:31:52 -0500
Content-Disposition: inline
In-Reply-To: <20170112214941.GE10203@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 10:49:41PM +0100, Andrew Lunn wrote:
> How are you using the PHY. What phy-mode do you have set?  Do you
> happen to be using it as an RGMII to SERDES/SGMII bridge? This is what
> Russell King is doing, i think.

No - the 88E1512 here is connected to the ethernet host via SGMII.

	Armada 8040 ----SGMII----> 88E1512 ----> RJ45

The problem that my commit fixes is that when the 88E1512 is used in
this mode, the copper page reflects the status of the RJ45-side link,
and the fiber page reflects the Armada 8040 side of the link.

Without my patch, the 88E1512 read_status function spots that the fiber
page reports its link is up (because the Armada 8040 side is indeed up)
and decides to report that as the link settings, rather than the
(correct) copper side.

> The point is, the phylib will continue polling the PHY registers,
> reading them. If the FIBRE is up, we want to read the FIBRE values,
> not the copper.

... but only if we aren't connected in SGMII mode to the ethernet host!

The 88E1512 has the RGMII pins, and it has the Serdes pins.  The Serdes
pins are used for the optical transceiver, or they're used for a SGMII
connection to an ethernet host.  So they can't do both.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
