From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 0/5] make cadence ethernet drivers build on any architecture
Date: Sun, 21 Oct 2012 16:23:07 +0200
Message-ID: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:65406 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab2JUOXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 10:23:34 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1170561lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 07:23:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series makes the at91_ether and macb driver build-able on any architecture.

Patch 1 removes the HAVE_NET_MACB from the cadence Kconfig and this allow macb to be built on any architecture. The macb driver requires no other modifications.

Patch 3 moves a bootloader quirk for CSB337 from at91_ether into CSB337 board setup. This allow us to remove the last mach include and build this driver on any architecture. It also make it easier to share the address setup between at91_ether and macb.

Patch 4-5 removes the now unused HAVE_NET_MACB config symbol from AT91/AVR32 Kconfig.


Note that patch 3 is not tested on a real CSB337 board. I only tested it on an other AT91RM9200 board to verify the logic that reverses the address byte order works.

The next series will make the at91_ether driver use address setting and statistics from macb. There is also a clean up of print outs plus some comment/style fixes.

Joachim Eastwood (5):
  net/cadence: get rid of HAVE_NET_MACB
  net/at91_ether: select MACB in Kconfig
  net/at91_ether: move eth addr quirk into csb337 board setup
  ARM: AT91: Remove HAVE_NET_MACB
  AVR32: Remove HAVE_NET_MACB

 arch/arm/mach-at91/Kconfig                |  4 ----
 arch/arm/mach-at91/board-csb337.c         | 35 +++++++++++++++++++++++++++++++
 arch/avr32/Kconfig                        |  1 -
 drivers/net/ethernet/cadence/Kconfig      |  8 +------
 drivers/net/ethernet/cadence/Makefile     |  2 +-
 drivers/net/ethernet/cadence/at91_ether.c | 26 ++++++-----------------
 6 files changed, 43 insertions(+), 33 deletions(-)

-- 
1.7.12.4
