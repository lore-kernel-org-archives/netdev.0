From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/7] net: bcmgenet: utilize MDIO unimac driver
Date: Mon, 31 Jul 2017 12:04:21 -0700
Message-ID: <20170731190429.24204-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35469 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdGaTEh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:04:37 -0400
Received: by mail-wr0-f194.google.com with SMTP id c24so28798467wra.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:04:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series migrates the Broadcom GENET driver to use the mdio-bcm-unimac
driver. This MDIO HW is the same as the one GENET internally embedds, yet for
historical reasons the two drivers lived their own lives. Because of the GENET
interrupt situation, we let it specify how it wants to signal MDIO operations
completion using its driver-private waitqueue.

The diffstat is not super impressive, but it's still negative! This would
make it easier in the future to absorb possible workarounds/bugs/features
within the same location.

This was tested on BCM7260 (GENETv5, single instance), BCM7439 (GENETv4, triple
instance) and BCM7445 (bcm_sf2 + mdio-bcm-unimac).

We also now have a nice /proc/iomem output:

f0b00000-f0b0fc4b : /rdb/ethernet@f0b00000
  f0b00e14-f0b00e1c : unimac-mdio.0
f0b20000-f0b2fc4b : /rdb/ethernet@f0b20000
  f0b20e14-f0b20e1c : unimac-mdio.1
f0b40000-f0b4fc4b : /rdb/ethernet@f0b40000
  f0b40e14-f0b40e1c : unimac-mdio.2


Florian Fainelli (7):
  net: phy: mdio-bcm-unimac: factor busy polling loop
  net: phy: mdio-bcm-unimac: create unique bus names
  net: phy: mdio-bcm-unimac: Add debug print for PHY workaround
  net: phy: mdio-bcm-unimac: Allow specifying platform data
  net: bcmgenet: utilize generic Broadcom UniMAC MDIO controller driver
  net: bcmgenet: Drop legacy MDIO code
  net: bcmgenet: Utilize bcmgenet_mii_exit() for error path

 MAINTAINERS                                    |   1 +
 drivers/net/ethernet/broadcom/Kconfig          |   1 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |   1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 256 ++++++++++---------------
 drivers/net/phy/mdio-bcm-unimac.c              |  71 ++++---
 include/linux/platform_data/mdio-bcm-unimac.h  |  13 ++
 6 files changed, 163 insertions(+), 180 deletions(-)
 create mode 100644 include/linux/platform_data/mdio-bcm-unimac.h

-- 
2.9.3
