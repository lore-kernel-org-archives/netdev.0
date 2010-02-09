From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 0/7] Add netdev_printk and netif_printk macros
Date: Tue,  9 Feb 2010 13:49:46 -0800
Message-ID: <cover.1265751023.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1901 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344Ab0BIVtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 16:49:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some logging messages duplicate the driver name with the device name like:

ATL1E 0000:03:00.0: ATL1E: eth0 NIC Link is Up<100 Mbps Full Duplex>
 
Some drivers/net/... have created netif_ macros like:

drivers/net/sis190.c:#define net_drv(p, arg...)		if (netif_msg_drv(p)) \
drivers/net/sis190.c-					printk(arg)
drivers/net/sis190.c:#define net_probe(p, arg...)	if (netif_msg_probe(p)) \
drivers/net/sis190.c-					printk(arg)
drivers/net/sis190.c:#define net_link(p, arg...)	if (netif_msg_link(p)) \
drivers/net/sis190.c-					printk(arg)
drivers/net/sis190.c:#define net_intr(p, arg...)	if (netif_msg_intr(p)) \
drivers/net/sis190.c-					printk(arg)
drivers/net/sis190.c:#define net_tx_err(p, arg...)	if (netif_msg_tx_err(p)) \
drivers/net/sis190.c-					printk(arg)

This RFC patch creates a set of these macros to standardize
the coding and logging style of struct net_device and netif_msg macros

I think they're useful, might be mindless churn to others.

The atl1e change reduces log duplicate names.

The qlge change is an example of what be mindless churn for standardization
sake, the r8169, jme, and skge are more reasonable.

Comments?

Joe Perches (7):
  netdevice.h: Add netdev_printk helpers like dev_printk
  drivers/net/atl1e: Use netdev_printk helpers
  include/linux/netdevice.h: Add netif_printk helpers
  drivers/net/r8196.c: Use netif_printk macros
  drivers/net/jme: Use netif_printk helpers
  drivers/net/qlge: Use netif_printk helpers
  drivers/net/skge.c: Use netif_printk macros

 drivers/net/atl1e/atl1e_hw.c    |   23 +-
 drivers/net/atl1e/atl1e_main.c  |  153 ++++----
 drivers/net/atl1e/atl1e_param.c |   35 +-
 drivers/net/jme.c               |   54 ++--
 drivers/net/jme.h               |   41 +--
 drivers/net/qlge/qlge.h         |    8 -
 drivers/net/qlge/qlge_dbg.c     |   58 ++--
 drivers/net/qlge/qlge_ethtool.c |   49 ++-
 drivers/net/qlge/qlge_main.c    |  841 ++++++++++++++++++++-------------------
 drivers/net/qlge/qlge_mpi.c     |  183 ++++-----
 drivers/net/r8169.c             |  136 +++----
 drivers/net/skge.c              |   73 ++--
 include/linux/netdevice.h       |  124 ++++++
 13 files changed, 914 insertions(+), 864 deletions(-)

