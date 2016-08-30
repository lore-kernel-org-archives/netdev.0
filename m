From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH 0/4] SA11x0 Clocks and removal of Neponset SMC91x hack
Date: Tue, 30 Aug 2016 11:51:17 +0100
Message-ID: <20160830105117.GM1041@n2100.armlinux.org.uk>
References: <20160829120531.GG1041@n2100.armlinux.org.uk>
 <E1beLKT-0001U1-HK@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@fluxnic.net>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:36567 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757315AbcH3Kv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 06:51:27 -0400
Content-Disposition: inline
In-Reply-To: <E1beLKT-0001U1-HK@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This mini-series (which follows several other series on which it
depends) gets rid of the Assabet/Neponset hack in the smc91x driver.

In order to do that, we need to get several pieces in place first:
* gpiolib support throughout SA11x0/Assabet/Neponset so that we can
  represent control signals through gpiolib
* CCF support, so we can re-use the code in drivers/clk to implement
  the external crystal oscillator attached to the SMC91x.  This
  external crystal oscillator is enabled via a control signal.

This series:
- performs the SA11x0 CCF conversion
- adds an optional clock to SMC91x to cater for an external crystal
  oscillator
- switches the Neponset code to provide a 'struct clk' representing
  this oscillator
- removes the SMC91x hack to assert the enable signal

This results in the platform specific includes being removed from the
SMC91x driver.

Please ack these changes; due to the dependencies, I wish to merge
them through my tree.  Thanks.

 arch/arm/Kconfig                   |   1 +
 arch/arm/mach-sa1100/clock.c       | 191 +++++++++++++++++--------------------
 arch/arm/mach-sa1100/neponset.c    |  42 ++++++++
 drivers/net/ethernet/smsc/smc91x.c |  47 ++++++---
 drivers/net/ethernet/smsc/smc91x.h |   1 +
 5 files changed, 166 insertions(+), 116 deletions(-)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
