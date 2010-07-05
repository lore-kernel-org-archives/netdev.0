From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v2 0/4] Extend Time Stamping
Date: Mon, 5 Jul 2010 07:30:45 +0200
Message-ID: <cover.1278307573.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44353 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab0GEFau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 01:30:50 -0400
Received: by bwz1 with SMTP id 1so2488155bwz.19
        for <netdev@vger.kernel.org>; Sun, 04 Jul 2010 22:30:49 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set extends the packet time stamping capabilites of the
network stack in two ways.

1. The first patch presents a work-around for the TX software time
   stamping fallback problem cited in cd4d8fdad1f1. The idea is to add
   two inline functions into each MAC driver. The functions will act
   as hooks for current (and possible future) time stamping needs,
   once they are placed correctly within each MAC driver.

2. The other patches prepare the way for PHY drivers to offer time
   stamping.

I am preparing a new round of patches for PTP support, but it will
require the changes in this patch set in order to function. Thus I
would like to have this patch set reviewed (and hopefully merged) in
order to go forward.

Thanks,
Richard

* Patch ChangeLog
** v2
   Removed the CONFIG option for the driver hooks.


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
 drivers/net/phy/mdio_bus.c             |   45 ++++++++++++++++++---
 drivers/net/phy/phy.c                  |    8 +++-
 drivers/net/sb1250-mac.c               |    2 +-
 drivers/net/sh_eth.c                   |    2 +-
 drivers/net/smsc911x.c                 |    2 +-
 drivers/net/smsc9420.c                 |    2 +-
 drivers/net/stmmac/stmmac_main.c       |   22 ++++-------
 drivers/net/tc35815.c                  |    2 +-
 drivers/net/tg3.c                      |    2 +-
 drivers/net/ucc_geth.c                 |    2 +-
 drivers/staging/octeon/ethernet-mdio.c |    2 +-
 include/linux/phy.h                    |   24 ++++++++++-
 include/linux/skbuff.h                 |   65 ++++++++++++++++++++++++++++++++
 net/Kconfig                            |   11 +++++
 net/dsa/slave.c                        |    3 +-
 29 files changed, 175 insertions(+), 54 deletions(-)

