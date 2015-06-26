From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/3] net: phy: bcm7xxx initial read/write workaround
Date: Fri, 26 Jun 2015 10:38:30 -0700
Message-ID: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34856 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbbFZRkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:40:09 -0400
Received: by pactm7 with SMTP id tm7so71821344pac.2
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:40:08 -0700 (PDT)
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
