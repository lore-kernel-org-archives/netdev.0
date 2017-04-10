From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH 0/6] mvmdio updates
Date: Mon, 10 Apr 2017 16:27:28 +0100
Message-ID: <20170410152728.GT17774@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>,
        netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>
To: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37622 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdDJP1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:27:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches update mvmdio for Armada 8k CP110.  A number of
issues were found:

1. The driver fails to disable an interrupt when something goes wrong
   in the probe function.

2. The interrupt is specified in DT to be optional, but the driver
   unconditionally writes to the interrupt mask register, which may
   not exist.

3. The DT binding specifies
    "reg: address and length of the SMI register"
   however, when supporting the interrupt, the size must cover the
   interrupt register as well.  Update the binding documentation
   with this information that was previously omitted.

4. If the register size is too small, have the driver print an error
   and disable use of the interrupt.

5. Armada 8k needs three clocks for the MDIO interface, otherwise the
   SoC hangs (since it is part of one of the ethernet interfaces.)
   GOP clock, MG core clock and MG clock are needed on 8k. Augment the
   binding and driver to allow three clocks to be specified.

 .../devicetree/bindings/net/marvell-orion-mdio.txt | 19 ++++++++--
 drivers/net/ethernet/marvell/mvmdio.c              | 44 +++++++++++++++++-----
 2 files changed, 50 insertions(+), 13 deletions(-)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
