From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next v2 0/6] gianfar: Device configuration fixes
Date: Mon, 17 Feb 2014 12:53:13 +0200
Message-ID: <1392634399-5456-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:47595
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751416AbaBQKxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 05:53:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset represents the first part of an effort
to solve some old device configuration issues in gianfar,
especially run-time reset and re-configuration problems.
I'm referring to "on-the-fly" configuration of registers
against HW specification, concurrency issues during device
reset / re-configuration operations, and implementing HW
advisories for these operations.

There's also a good deal of code cleanup and refactoring,
and some other (minor) fixes as well.

Thank you. 
--
v2: Remove sysfs stubs w/o replacing them with module
    params (patch 2).

Claudiu Manoil (6):
  gianfar: Cleanup/Fix gfar_probe and the hw init code
  gianfar: Remove sysfs stubs for FIFOCFG and stashing
  gianfar: Remove useless HAS_PADDING device flag
  gianfar: Factor out enabling/disabling of hw interrupts
  gianfar: Add missing graceful reset steps and fixes
  gianfar: Remove clean_rx_ring race from gfar_ethtool

 Documentation/networking/gianfar.txt             |  30 --
 drivers/net/ethernet/freescale/Makefile          |   3 +-
 drivers/net/ethernet/freescale/gianfar.c         | 500 +++++++++++------------
 drivers/net/ethernet/freescale/gianfar.h         |  44 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c |  64 +--
 drivers/net/ethernet/freescale/gianfar_sysfs.c   | 340 ---------------
 6 files changed, 278 insertions(+), 703 deletions(-)
 delete mode 100644 drivers/net/ethernet/freescale/gianfar_sysfs.c

-- 
1.7.11.7
