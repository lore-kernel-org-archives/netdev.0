From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 0/4] Altera Triple Speed Ethernet (TSE) Driver
Date: Thu, 24 Apr 2014 16:58:07 -0500
Message-ID: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:50668 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319AbaDXWCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:02:33 -0400
Received: by mail-pa0-f45.google.com with SMTP id kq14so1749100pab.18
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 15:02:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches addresses a handful of issues found in testing
and reported by users of the Altera Triple Speed Ethernet soft IP.

The patches address the following issues (in summary)

1) The SGDMA soft IP was found to incorrectly process receive packets
   when the target physical address of the receive buffer was on
   a boundary that's not 32-bit aligned. One of the patches addresses
   this issue.
2) The pause quanta was not being set by the driver, one patch of this
   series sets the pause quanta to the IEEE defined default value
   since the hardware reset value is 0.
3) An issue in a error recovery path of the probe routine caused a 
   kernel panic in the event a phy was probed and could not be found.
   A patch addresses this issue. 
4) A change was made to the driver name for Ethtool support, and 
   comments added to support an addition to Ethtool to support
   the Altera Triple Speed Ethernet controller.

If you find this patch series acceptable, please consider this series
for inclusion when possible. 

Thank you, 

Vince

Vince Bridgers (4):
  Altera TSE: Work around unaligned DMA receive packet issue with
    Altera SGDMA
  Altera TSE: Set the Pause Quanta value to the IEEE default value
  Altera TSE: Fix Panic in probe routine when phy probe fails
  Altera TSE: Change driver name used by Ethtool

 drivers/net/ethernet/altera/altera_msgdma.c      |    7 +-
 drivers/net/ethernet/altera/altera_msgdma.h      |    3 +-
 drivers/net/ethernet/altera/altera_sgdma.c       |  105 ++++++++++++++--------
 drivers/net/ethernet/altera/altera_sgdma.h       |    3 +-
 drivers/net/ethernet/altera/altera_tse.h         |    6 +-
 drivers/net/ethernet/altera/altera_tse_ethtool.c |    8 +-
 drivers/net/ethernet/altera/altera_tse_main.c    |   77 +++++++++-------
 7 files changed, 136 insertions(+), 73 deletions(-)

-- 
1.7.9.5
