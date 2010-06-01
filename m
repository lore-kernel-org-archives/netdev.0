From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 00/12] sfc changes for 2.6.36
Date: Tue, 01 Jun 2010 22:16:07 +0100
Message-ID: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50325 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694Ab0FAVQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:16:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a first series of changes for 2.6.36.

The major feature here is RX buffer recycling, which improves
performance on networks with heavy multicast traffic.  Other than that,
there are various bug fixes and cleanup.

Ben.

Ben Hutchings (3):
  sfc: Rename struct efx_mcdi_phy_cfg to efx_mcdi_phy_data
  sfc: Only count bad packets in rx_errors
  sfc: Get port number from CS_PORT_NUM, not PCI function number

Steve Hodgson (9):
  sfc: Reschedule any resets scheduled inside efx_pm_freeze()
  sfc: Workaround flush failures on Falcon B0
  sfc: Synchronise link_advertising and wanted_fc on Siena
  sfc: Wait for the link to stay up before running loopback selftest
  sfc: Allow DRV_GEN events to be used outside of selftests
  sfc: Remove efx_rx_queue::add_lock
  sfc: Support only two rx buffers per page
  sfc: Recycle discarded rx buffers back onto the queue
  sfc: Allow shared pages to be recycled

 drivers/net/sfc/efx.c         |   69 +++-----
 drivers/net/sfc/efx.h         |    4 +-
 drivers/net/sfc/falcon.c      |    8 +-
 drivers/net/sfc/mcdi_phy.c    |   21 ++-
 drivers/net/sfc/net_driver.h  |   46 +++--
 drivers/net/sfc/nic.c         |   55 +++++--
 drivers/net/sfc/nic.h         |    4 +-
 drivers/net/sfc/rx.c          |  393 +++++++++++++++++++----------------------
 drivers/net/sfc/selftest.c    |   26 ++--
 drivers/net/sfc/siena.c       |    4 +
 drivers/net/sfc/workarounds.h |    2 +-
 11 files changed, 317 insertions(+), 315 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

