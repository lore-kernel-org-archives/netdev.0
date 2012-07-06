From: <s-paulraj@ti.com>
Subject: [PATCH 0/4] phylib: add context argument to adjust link callbacks
Date: Fri, 6 Jul 2012 15:57:33 -0400
Message-ID: <1341604653-19944-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sandeep Paulraj <s-paulraj@ti.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>, <cyril@ti.com>,
	<grant.likely@secretlab.ca>, <linux-keystone@list.ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:54324 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483Ab2GFT5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 15:57:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Paulraj <s-paulraj@ti.com>

This series of 4 patches adds a new context argument for the adjust link
callbacks. The existing phy_connect() and its variants don't have a way to
pass any private context information. This becomes necessary when, a SOC
has an on chip switch with multiple ports. We need port specific information
to figure out which port a given callback belongs to.
We can pass this context information in the phy_connect() and its
variants. This in turn gets passed into the adjust link callbacks on link
state change events.

NOTE: At this point of time patch 4 in this series passes a "NULL" to
the phy_connect() and its variants for all drivers that currently use
phy_connect() and its variants. This patch has been tested on a
Texas Instruments SOC, patches for which, as of now have not yet been
upstreamed; as a result of which this patch series does not yet
have an example of how this new feature is being actually used.

Sandeep Paulraj (4):
  phylib: factor out handler callouts into helper
  phylib: add context argument to adjust link callback
  of/mdio: add context argument to adjust link callback
  net: add context callback parameter to phy connect

 drivers/net/ethernet/8390/ax88796.c                |    4 ++--
 drivers/net/ethernet/adi/bfin_mac.c                |    4 ++--
 drivers/net/ethernet/aeroflex/greth.c              |    7 +++---
 drivers/net/ethernet/amd/au1000_eth.c              |    4 ++--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |    4 ++--
 drivers/net/ethernet/broadcom/sb1250-mac.c         |    6 ++---
 drivers/net/ethernet/broadcom/tg3.c                |    4 ++--
 drivers/net/ethernet/cadence/macb.c                |    4 ++--
 drivers/net/ethernet/dnet.c                        |    6 ++---
 drivers/net/ethernet/ethoc.c                       |    4 ++--
 drivers/net/ethernet/faraday/ftgmac100.c           |    4 ++--
 drivers/net/ethernet/freescale/fec.c               |    4 ++--
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    5 ++--
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    6 ++---
 drivers/net/ethernet/freescale/gianfar.c           |    8 +++----
 drivers/net/ethernet/freescale/ucc_geth.c          |    6 ++---
 drivers/net/ethernet/lantiq_etop.c                 |    4 ++--
 drivers/net/ethernet/nxp/lpc_eth.c                 |    5 ++--
 drivers/net/ethernet/octeon/octeon_mgmt.c          |    4 ++--
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    4 ++--
 drivers/net/ethernet/rdc/r6040.c                   |    4 ++--
 drivers/net/ethernet/renesas/sh_eth.c              |    4 ++--
 drivers/net/ethernet/s6gmac.c                      |    4 ++--
 drivers/net/ethernet/smsc/smsc911x.c               |    4 ++--
 drivers/net/ethernet/smsc/smsc9420.c               |    5 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    6 +++--
 drivers/net/ethernet/ti/cpmac.c                    |    4 ++--
 drivers/net/ethernet/ti/cpsw.c                     |    5 ++--
 drivers/net/ethernet/ti/davinci_emac.c             |    4 ++--
 drivers/net/ethernet/toshiba/tc35815.c             |    5 ++--
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    4 ++--
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |    3 ++-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |    5 ++--
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |    4 ++--
 drivers/net/phy/phy.c                              |   25 ++++++++++++--------
 drivers/net/phy/phy_device.c                       |   23 +++++++++++-------
 drivers/of/of_mdio.c                               |   24 ++++++++++++-------
 include/linux/of_mdio.h                            |   15 ++++++------
 include/linux/phy.h                                |   20 +++++++++-------
 39 files changed, 149 insertions(+), 116 deletions(-)

-- 
1.7.9.5
