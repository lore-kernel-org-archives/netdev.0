From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH v3 0/3] phylib EEE updates
Date: Fri, 31 Mar 2017 10:36:46 +0100
Message-ID: <20170331093645.GA15329@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:48466 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753535AbdCaJg5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 05:36:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

This series of patches depends on the previous set of changes, and is
therefore net-next material.

While testing the EEE code, I discovered a number of issues:

1. It is possible to enable advertisment of EEE modes which are not
   supported by the hardware.  We omit to check the supported modes
   and mask off those modes that are not supported before writing the
   EEE advertisment register.

2. We need to restart autonegotiation after a change of the EEE
   advertisment, otherwise the link partner does not see the updated
   EEE modes.

3. SGMII connected PHYs are also capable of supporting EEE.

Through discussion with Florian, it has been decided to remove the check
for the PHY interface mode in patch (3).

 drivers/net/phy/phy.c | 37 ++++++++++++++++++++++++++-----------
 1 file changed, 26 insertions(+), 11 deletions(-)

v2: fix "phy_restart_aneg" build error identified by 0-day
v3: drop RFC tag, replace 3rd patch

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
