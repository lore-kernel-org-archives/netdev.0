From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 0/5] net: w5100: add support W5100/W5200 for SPI interface
Date: Fri, 15 Apr 2016 00:11:28 +0900
Message-ID: <1460646693-25179-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35265 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbcDNPLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 11:11:50 -0400
Received: by mail-pf0-f181.google.com with SMTP id n1so46904779pfn.2
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 08:11:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series add support for Wiznet W5100 and W5200 for SPI interface.

We can easily find the ethernet modules and shield for Arduino with
these chips for purchase.  I've tested them with BeagleBone.

Wiznet W5100 for mmio access has already supported by w5100 driver.

In order to share the code between mmio mode and SPI mode, this series
firstly adds ability to support another register access interface to
the existing w5100 driver.  This ground work also requires to introduce
workqueue and threaded irq because SPI transfers are callable only from
contexts that can sleep unlike mmio access.

The latter part of this series adds w5100-spi driver which actually
support W5100 and W5200 for SPI interface.  Supporting W5100 is
straight forward because it only required to add a register access
interface by the SPI transfer.  W5100 and W5200 have similar memory
map which justifies adding W5200 support to w5100 driver.

* Changes from v2 to v3
- Add comment for reg_lock
- Add ability to allocate ops specific data structure
- Allocate w5200 ops specific data structure to put DMA-safe buffer
- Add missing chip_id assignment for w5100_*_ops

* Changes from v1 to v2
- Use a plain single pointer instead of SKB queue, spotted by David S. Miller
- Correct timeout period in w5100_command
- Use spi_write_then_read instead of spi_write which needs DMA-safe buffer
- Support W5200


Akinobu Mita (5):
  net: w5100: move mmiowb into register access callbacks
  net: w5100: add ability to support other bus interface
  net: w5100: enable to support sleepable register access interface
  net: w5100: support SPI interface mode
  net: w5100: support W5200

 drivers/net/ethernet/wiznet/Kconfig     |  14 +
 drivers/net/ethernet/wiznet/Makefile    |   1 +
 drivers/net/ethernet/wiznet/w5100-spi.c | 300 ++++++++++
 drivers/net/ethernet/wiznet/w5100.c     | 935 ++++++++++++++++++++++----------
 drivers/net/ethernet/wiznet/w5100.h     |  35 ++
 5 files changed, 1004 insertions(+), 281 deletions(-)
 create mode 100644 drivers/net/ethernet/wiznet/w5100-spi.c
 create mode 100644 drivers/net/ethernet/wiznet/w5100.h

Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
-- 
2.5.0
