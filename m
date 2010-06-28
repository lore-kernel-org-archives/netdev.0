From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/4] Extend Time Stamping
Date: Mon, 28 Jun 2010 17:33:38 +0200
Message-ID: <cover.1277737222.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:20070 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208Ab0F1Pdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 11:33:38 -0400
Received: by fg-out-1718.google.com with SMTP id e21so497563fga.1
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 08:33:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set extends the packet time stamping capabilites of the
network stack in two ways.

1. The first patch presents a work-around for the TX software time
   stamping fallback problem cited in cd4d8fdad1f1. The idea is to add
   two inline functions into each MAC driver. The functions act as
   hooks which are only present if certain CONFIG options are enabled.

2. The other patches prepare the way for PHY drivers to offer time
   stamping.

I am preparing a new round of patches for PTP support, but it will
require the changes in this patch set in order to function. Thus I
would like to have this patch set reviewed (and hopefully merged) in
order to go forward.

Thanks,
Richard


Richard Cochran (4):
  net: add driver hooks for time stamping.
  phylib: add a way to make PHY time stamps possible.
  phylib: preserve ifreq parameter when calling generic phy_mii_ioctl()
  phylib: Allow reading and writing a mii bus from atomic context.

 drivers/net/arm/ixp4xx_eth.c           |    3 +-
 drivers/net/au1000_eth.c               |    2 +-
 drivers/net/bcm63xx_enet.c             |    2 +-
 drivers/net/cpmac.c                    |    5 +--
 drivers/net/dnet.c                     |    2 +-
 drivers/net/ethoc.c                    |    2 +-
 drivers/net/fec.c                      |    2 +-
 drivers/net/fec_mpc52xx.c              |    2 +-
 drivers/net/fs_enet/fs_enet-main.c     |    3 +-
 drivers/net/fsl_pq_mdio.c              |    4 +-
 drivers/net/gianfar.c                  |    2 +-
 drivers/net/macb.c                     |    2 +-
 drivers/net/mv643xx_eth.c              |    2 +-
 drivers/net/octeon/octeon_mgmt.c       |    2 +-
 drivers/net/phy/mdio_bus.c             |   45 +++++++++++++++++---
 drivers/net/phy/phy.c                  |    8 +++-
 drivers/net/sb1250-mac.c               |    2 +-
 drivers/net/sh_eth.c                   |    2 +-
 drivers/net/smsc911x.c                 |    2 +-
 drivers/net/smsc9420.c                 |    2 +-
 drivers/net/stmmac/stmmac_main.c       |   22 ++++------
 drivers/net/tc35815.c                  |    2 +-
 drivers/net/tg3.c                      |    2 +-
 drivers/net/ucc_geth.c                 |    2 +-
 drivers/staging/octeon/ethernet-mdio.c |    2 +-
 include/linux/phy.h                    |   24 +++++++++-
 include/linux/skbuff.h                 |   71 ++++++++++++++++++++++++++++++++
 net/Kconfig                            |   22 ++++++++++
 net/dsa/slave.c                        |    3 +-
 29 files changed, 192 insertions(+), 54 deletions(-)

