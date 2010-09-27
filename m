From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 00/17] netdev: Fix queue count initialisation
Date: Mon, 27 Sep 2010 19:23:11 +0100
Message-ID: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50867 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757190Ab0I0SXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:23:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the functions:
- netif_set_real_num_rx_queues() - set actual number of RX queues used
- netif_copy_real_num_queues() - copy queue counts from another device

and changes all drivers that currently set
net_device::real_num_tx_queues to use netif_set_real_num_tx_queues()
and/or these functions.

The changes are compile-tested only, except that:
- sfc and 8021q have been briefly tested
- gianfar and mv643xx_eth have not been compiled, since they are
  platform-specific

I noticed that the bonding driver sets its numbers of queues without
regard to its slave devices.  This makes some sense since a bond device
initially has no slave devices.  However, it seems to mean that a bond
device can pass up an skb with an out-of-range queue_index, triggering a
warning in get_rps_cpu().

Ben.

Ben Hutchings (17):
  net: Allow changing number of RX queues after device allocation
  net: Add netif_copy_real_num_queues() for use by virtual net drivers
  bnx2: Use netif_set_real_num_{rx,tx}_queues()
  bnx2x: Use netif_set_real_num_{rx,tx}_queues()
  cxgb3: Use netif_set_real_num_{rx,tx}_queues()
  cxgb4: Use netif_set_real_num_{rx,tx}_queues()
  cxgb4vf: Use netif_set_real_num_{rx,tx}_queues()
  gianfar: Use netif_set_real_num_rx_queues()
  igb: Use netif_set_real_num_{rx,tx}_queues()
  ixgbe: Use netif_set_real_num_{rx,tx}_queues()
  mlx4_en: Use netif_set_real_num_{rx,tx}_queues()
  mv643xx_eth: Use netif_set_real_num_{rx,tx}_queues()
  myri10ge: Use netif_set_real_num_{rx,tx}_queues()
  niu: Use netif_set_real_num_{rx,tx}_queues()
  sfc: Use netif_set_real_num_{rx,tx}_queues()
  tg3: Use netif_set_real_num_{rx,tx}_queues()
  8021q: Use netif_copy_real_num_queues() to set queue counts

 drivers/net/bnx2.c                 |    9 ++++--
 drivers/net/bnx2x/bnx2x_cmn.c      |    6 +++-
 drivers/net/cxgb3/cxgb3_main.c     |    5 +++-
 drivers/net/cxgb4/cxgb4_main.c     |    5 +++-
 drivers/net/cxgb4vf/cxgb4vf_main.c |    5 +++-
 drivers/net/gianfar.c              |    3 +-
 drivers/net/igb/igb_main.c         |   12 ++++++---
 drivers/net/ixgbe/ixgbe_main.c     |   16 ++++++++----
 drivers/net/mlx4/en_netdev.c       |    3 +-
 drivers/net/mv643xx_eth.c          |    3 +-
 drivers/net/myri10ge/myri10ge.c    |    5 ++-
 drivers/net/niu.c                  |    3 +-
 drivers/net/sfc/efx.c              |    3 +-
 drivers/net/tg3.c                  |    8 ++++-
 include/linux/netdevice.h          |   28 +++++++++++++++++++++-
 net/8021q/vlan.c                   |    2 +-
 net/core/dev.c                     |   45 ++++++++++++++++++++++++++++++++---
 net/core/net-sysfs.c               |   34 +++++++++++++++------------
 net/core/net-sysfs.h               |    4 +++
 19 files changed, 151 insertions(+), 48 deletions(-)

-- 
1.7.2.1

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

