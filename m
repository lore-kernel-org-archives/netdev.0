From: Kosta Zertsekel <konszert@marvell.com>
Subject: Fix phy_init for Marvell network eth driver
Date: Thu, 10 Jan 2013 14:00:32 +0200
Message-ID: <1357819234-27752-1-git-send-email-konszert@marvell.com>
Cc: zertsekel@gmail.com, andrew@lunn.ch, benavi@marvell.com,
	linux-arm-kernel@lists.infradead.org, alior@marvell.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:60794 "EHLO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750984Ab3AJMJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 07:09:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
resubmitting the patch for Marvell mv643xx driver (patch 1/2) adding the below explanation (thanks to Florian F.):
The D-Link DNS323_REV_C1 board has a specific PHY device fixup using the flag MARVELL_PHY_M1118_DNS323_LEDS which is set by the architecture code in arch/arm/mach-orion5x/dns323-setup.c. This flag is unfortunately lost during the call to phy_attach() in mv643xx_eth and therefore, the underlying Marvell PHY driver cannot make use of this flag to fixup the PHY device LEDs. This patch ensures the phy->dev_flags value is passed to the phy_attach() function such that the PHY device driver can
actually use it.

Also submitting new patch 2/2 using the same (or at least very close in meaning) explanation.
