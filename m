From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: phy: bcm7xxx initial read/write workaround
Date: Fri, 26 Jun 2015 10:39:03 -0700
Message-ID: <1435340346-10297-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35896 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbbFZRki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:40:38 -0400
Received: by pdcu2 with SMTP id u2so78788838pdc.3
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:40:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series fixes occasional BCM7xxx PHY driver binding failure due
to a harware bug where the first read or write does not come out of the PHY
MDIO management controller.

Since we have two different MDIO controllers using this PHY, a similar
need to be replicated in GENET and UniMAC MDIO.

Thanks!

Florian Fainelli (3):
  net: phy: bcm7xxx: workaround MDIO management controller initial read
  net: bcmgenet: workaround initial read failures for integrated PHYs
  net: phy: mdio-bcm-unimac: workaround initial read failures for
    integrated PHYs

 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 54 ++++++++++++++++++++++++--
 drivers/net/phy/bcm7xxx.c                      |  7 ++++
 drivers/net/phy/mdio-bcm-unimac.c              | 43 ++++++++++++++++++++
 4 files changed, 101 insertions(+), 4 deletions(-)

-- 
2.1.0
