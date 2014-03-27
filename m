From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 00/14] net: remove empty MDIO bus reset functions
Date: Wed, 26 Mar 2014 18:07:12 -0700
Message-ID: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:57874 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbaC0BHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:07:39 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so2715061pbb.39
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:07:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patchset removes all empty MDIO bus reset functions that we have in the
tree (hopefully all of them). This function is optional for the MDIO bus code in
drivers/net/phy/mdio_bus.c::mdiobus_register, the documentation is updated to
reflect that.

Having less call sites to update will allow us to implement a generic BMCR_RESET
based PHY reset for MDIO buses that require to reset their PHYs before their
PHY detection succeeds (e.g: HiSilicon hip04 current submission) and provide it
as a helper.

Thanks!

Florian Fainelli (14):
  net: greth: remove empty MDIO bus reset function
  tg3: remove empty MDIO bus reset function
  macb: remove empty MDIO bus reset function
  dnet: remove empty MDIO bus reset function
  net: ethoc: remove empty MDIO bus function
  fec: remove empty MDIO bus function
  fs_enet: remove empty MDIO bus function
  net: mvmdio: remove empty MDIO bus reset function
  net: emaclite: remove empty MDIO bus reset function
  net: sun4i: remove empty MDIO bus reset function
  net: ftgmac100: remove empty MDIO bus reset function
  r6040: remove empty MDIO bus reset function
  bfin_mac: remove empty MDIO bus reset function
  Documentation: networking: phy.txt: MDIO bus reset is optional

 Documentation/networking/phy.txt                 |  2 +-
 drivers/net/ethernet/adi/bfin_mac.c              |  6 ------
 drivers/net/ethernet/aeroflex/greth.c            |  6 ------
 drivers/net/ethernet/broadcom/tg3.c              |  6 ------
 drivers/net/ethernet/cadence/macb.c              |  6 ------
 drivers/net/ethernet/dnet.c                      |  6 ------
 drivers/net/ethernet/ethoc.c                     |  6 ------
 drivers/net/ethernet/faraday/ftgmac100.c         |  6 ------
 drivers/net/ethernet/freescale/fec_main.c        |  6 ------
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c |  7 -------
 drivers/net/ethernet/marvell/mvmdio.c            |  6 ------
 drivers/net/ethernet/rdc/r6040.c                 |  6 ------
 drivers/net/ethernet/xilinx/xilinx_emaclite.c    | 13 -------------
 drivers/net/phy/mdio-sun4i.c                     |  6 ------
 14 files changed, 1 insertion(+), 87 deletions(-)

-- 
1.8.3.2
