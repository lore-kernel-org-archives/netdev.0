From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 0/8] sfc and ethtool changes for 2.6.37
Date: Mon, 20 Sep 2010 19:40:56 +0100
Message-ID: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7046 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338Ab0ITSk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:40:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds Ethernet-level filtering and explicit filter clearing
to the ethtool RX n-tuple interface, and implements it in the sfc
driver.

There is a cleanup patch on the end which is preparation for the
following RFC patch series but is worthwhile anyway.

Ben.

Ben Hutchings (8):
  ethtool: Define RX n-tuple action to clear a rule
  ethtool: Add Ethernet MAC-level filtering/steering
  ethtool: Allocate register dump buffer with vmalloc()
  sfc: Add filter table management
  sfc: Implement the ethtool RX n-tuple control functions
  sfc: Include RX IP filter table in register dump
  sfc: Set net_device::num_rx_queues once we know the correct value
  sfc: Clean up and correct comments on efx_monitor()

 drivers/net/sfc/Makefile     |    2 +-
 drivers/net/sfc/efx.c        |   35 ++--
 drivers/net/sfc/efx.h        |   14 ++
 drivers/net/sfc/ethtool.c    |  118 +++++++++++-
 drivers/net/sfc/falcon.c     |    2 +-
 drivers/net/sfc/filter.c     |  445 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/filter.h     |  189 ++++++++++++++++++
 drivers/net/sfc/net_driver.h |    4 +
 drivers/net/sfc/nic.c        |    5 +-
 drivers/net/sfc/regs.h       |   14 ++
 drivers/net/sfc/siena.c      |    2 +-
 include/linux/ethtool.h      |   11 +-
 net/core/ethtool.c           |    4 +-
 13 files changed, 819 insertions(+), 26 deletions(-)
 create mode 100644 drivers/net/sfc/filter.c
 create mode 100644 drivers/net/sfc/filter.h

-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

