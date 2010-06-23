From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 0/5] sfc changes for 2.6.36
Date: Wed, 23 Jun 2010 22:27:27 +0100
Message-ID: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18415 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab0FWV1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 17:27:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series changes logging to use the new netif_* macros (except in the
MTD driver) and adds RX hash offload.

Ben.

Ben Hutchings (5):
  sfc: Log MTD errors using partition name, not just net device name
  sfc: Implement message level control
  sfc: Replace EFX_DRIVER_NAME with KBUILD_MODNAME
  sfc: Disable setting feature flags that are not implemented
  sfc: Record hardware RX hash on each skb where possible

 drivers/net/sfc/efx.c           |  226 +++++++++++++++++++++++---------------
 drivers/net/sfc/efx.h           |    5 +-
 drivers/net/sfc/ethtool.c       |   61 ++++++++---
 drivers/net/sfc/falcon.c        |  180 +++++++++++++++++++------------
 drivers/net/sfc/falcon_boards.c |   30 +++---
 drivers/net/sfc/falcon_xmac.c   |    5 +-
 drivers/net/sfc/io.h            |   30 +++--
 drivers/net/sfc/mcdi.c          |   98 ++++++++++-------
 drivers/net/sfc/mcdi_mac.c      |    8 +-
 drivers/net/sfc/mcdi_phy.c      |   20 ++--
 drivers/net/sfc/mdio_10g.c      |   39 ++++---
 drivers/net/sfc/mdio_10g.h      |    3 +-
 drivers/net/sfc/mtd.c           |   23 +++--
 drivers/net/sfc/net_driver.h    |   43 ++------
 drivers/net/sfc/nic.c           |  219 +++++++++++++++++++++----------------
 drivers/net/sfc/qt202x_phy.c    |   42 ++++---
 drivers/net/sfc/rx.c            |   79 ++++++++++----
 drivers/net/sfc/selftest.c      |  129 +++++++++++++---------
 drivers/net/sfc/siena.c         |   47 +++++---
 drivers/net/sfc/tenxpress.c     |   12 ++-
 drivers/net/sfc/tx.c            |   41 ++++---
 21 files changed, 793 insertions(+), 547 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

