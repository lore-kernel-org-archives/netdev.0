From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH RFC v2 0/2] phylib non-autoneg speed setting
Date: Thu, 6 Apr 2017 11:00:33 +0100
Message-ID: <20170406100033.GA24671@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50948 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755423AbdDFKAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 06:00:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of two patches fixes and cleans up the phylib code associated
with selecting the fixed mode.

phylib currently assumes that all PHYs will support the 10baseT/Half mode
of operation irrespective of the supported bitmask, because of the way
phy_find_valid() and phy_find_setting() operate.

This series resolves that by reimplementing the table lookup, filtering
out all unsupported modes.  This results in an unsupported speed setting
always choosing one of the speeds that are supported by the PHY.  Full
details are in the patch commit log.

The second patch cleans up the loop in phy_supported_speeds().

 drivers/net/phy/phy.c | 119 ++++++++++++++++++++++++++++----------------------
 1 file changed, 68 insertions(+), 51 deletions(-)

v1->v2: fixed 0-day build errors

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
