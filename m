From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/5] sfc: Firmware-Assisted TSO version 2
Date: Thu, 17 Nov 2016 10:49:42 +0000
Message-ID: <ae6b02ca-9a0b-7072-6914-294fc9adb684@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:48801 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S941900AbcKQKtz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 05:49:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware on 8000 series SFC NICs supports a new TSO API ("FATSOv2"), and
 7000 series NICs will also support this in an imminent release.  This series
 adds driver support for this TSO implementation.
The series also removes SWTSO, as it's now equivalent to GSO.  This does not
 actually remove very much code, because SWTSO was grotesquely intertwingled
 with FATSOv1, which will also be removed once 7000 series supports FATSOv2.


Bert Kenward (1):
  sfc: Firmware-Assisted TSO version 2

Edward Cree (4):
  sfc: Update MCDI protocol definitions
  sfc: Update EF10 register definitions
  sfc: handle failure to allocate TSOv2 contexts
  sfc: remove Software TSO

 drivers/net/ethernet/sfc/Makefile     |    2 +-
 drivers/net/ethernet/sfc/ef10.c       |  158 ++++-
 drivers/net/ethernet/sfc/ef10_regs.h  |  103 +++-
 drivers/net/ethernet/sfc/efx.c        |   38 +-
 drivers/net/ethernet/sfc/ethtool.c    |    2 +
 drivers/net/ethernet/sfc/falcon.c     |    2 +
 drivers/net/ethernet/sfc/farch.c      |   15 +
 drivers/net/ethernet/sfc/mcdi_pcol.h  |  483 ++++++++++++++-
 drivers/net/ethernet/sfc/net_driver.h |   52 +-
 drivers/net/ethernet/sfc/nic.h        |    2 +
 drivers/net/ethernet/sfc/siena.c      |    1 +
 drivers/net/ethernet/sfc/tx.c         | 1047 +++++++++------------------------
 drivers/net/ethernet/sfc/tx.h         |   27 +
 drivers/net/ethernet/sfc/tx_tso.c     |  452 ++++++++++++++
 14 files changed, 1558 insertions(+), 826 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/tx.h
 create mode 100644 drivers/net/ethernet/sfc/tx_tso.c
