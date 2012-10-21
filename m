From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH v2 0/3] make cadence ethernet drivers build on any architecture
Date: Sun, 21 Oct 2012 23:57:00 +0200
Message-ID: <1350856623-9819-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:53103 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617Ab2JUV5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 17:57:23 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so1238149lag.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 14:57:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series makes the at91_ether and macb driver build-able on any architecture.

Patch 1 removes the HAVE_NET_MACB from the cadence Kconfig and this allow macb to be built on any architecture. The macb driver requires no other modifications.

Patch 3 moves a bootloader quirk for CSB337 from at91_ether into platform data as a flag. This allow us to remove the last mach include and build this driver on any architecture. It also make it easier to share the address setup between at91_ether and macb.


The next series will make the at91_ether driver use address setting and statistics from macb. There is also a clean up of print outs plus some comment/style fixes.

Joachim Eastwood (3):
  net/cadence: get rid of HAVE_NET_MACB
  net/at91_ether: select MACB in Kconfig
  net/at91_ether: add pdata flag for reverse Eth addr

 arch/arm/mach-at91/Kconfig                | 4 ----
 arch/arm/mach-at91/board-csb337.c         | 2 ++
 arch/avr32/Kconfig                        | 1 -
 drivers/net/ethernet/cadence/Kconfig      | 8 +-------
 drivers/net/ethernet/cadence/Makefile     | 2 +-
 drivers/net/ethernet/cadence/at91_ether.c | 5 ++---
 include/linux/platform_data/macb.h        | 1 +
 7 files changed, 7 insertions(+), 16 deletions(-)

-- 
1.7.12.4
