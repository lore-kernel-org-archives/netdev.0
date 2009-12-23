From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/8] sfc: Fixes for 2.6.33
Date: Wed, 23 Dec 2009 23:46:08 +0000
Message-ID: <1261611970.2782.86.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28139 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbZLWXqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:46:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

There are a few important bug fixes that should go into 2.6.33.  I
regret that some of the workarounds for the QT2025C are rather large.

Ben.

Ben Hutchings (3):
  sfc: Include XGXS in XMAC link status check except in XGMII loopback
  sfc: QT2025C: Add error message for suspected bad SFP+ cables
  sfc: Disable TX descriptor prefetch watchdog

Matthew Slattery (3):
  sfc: QT2025C: Work around PHY bug
  sfc: QT2025C: Switch into self-configure mode when not in loopback
  sfc: QT2025C: Work around PHY firmware initialisation bug

Neil Turton (1):
  sfc: Fix DMA mapping cleanup in case of an error in TSO

Steve Hodgson (1):
  sfc: Move PHY software state initialisation from init() into probe()

 drivers/net/sfc/efx.c         |    6 +-
 drivers/net/sfc/falcon.c      |    1 +
 drivers/net/sfc/falcon_xmac.c |   38 ++++---
 drivers/net/sfc/mcdi_phy.c    |   93 ++++++----------
 drivers/net/sfc/net_driver.h  |    1 +
 drivers/net/sfc/nic.c         |    2 +
 drivers/net/sfc/qt202x_phy.c  |  238 ++++++++++++++++++++++++++++++++++++++---
 drivers/net/sfc/siena.c       |    1 +
 drivers/net/sfc/tenxpress.c   |  138 +++++++++++++-----------
 drivers/net/sfc/tx.c          |    4 +-
 10 files changed, 369 insertions(+), 153 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

