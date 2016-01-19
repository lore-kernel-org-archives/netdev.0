From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: phy: Finally fix PHY_IGNORE_INTERRUPTS
Date: Mon, 18 Jan 2016 19:33:05 -0800
Message-ID: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com, Woojung.Huh@microchip.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33142 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755726AbcASDdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 22:33:55 -0500
Received: by mail-pa0-f41.google.com with SMTP id cy9so443904092pac.0
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 19:33:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series finally fixes how PHY_IGNORE_INTERRUPTS are treated by
avoiding to poll the PHY *and* getting notified from link state changes by the
Ethernet MAC interrupt service routine.

Tested with bcmgenet since this is the HW that I have access to.

Targetting the "net" tree since these are bugfixes, but I would like Woojun and
Andrew to take a look and test that on their respective HW setups as well.

Thank you!

Florian Fainelli (3):
  net: phy: Avoid polling PHY with PHY_IGNORE_INTERRUPTS
  net: phy: Fix phy_mac_interrupt()
  net: bcmgenet: Properly configure PHY to ignore interrupt

 drivers/net/ethernet/broadcom/genet/bcmmii.c |  2 +-
 drivers/net/phy/phy.c                        | 46 +++++++++++++++++-----------
 2 files changed, 29 insertions(+), 19 deletions(-)

-- 
2.1.0
