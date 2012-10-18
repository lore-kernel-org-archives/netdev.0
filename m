From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 00/12] at91_ether cleanup
Date: Thu, 18 Oct 2012 23:01:05 +0200
Message-ID: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:59632 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932110Ab2JRVBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 17:01:34 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so6209827lbo.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 14:01:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This patch series prepares the old at91_ether driver for code sharing with the macb driver. The hardware is similar except for DMA TX/RX, so its not quite clear if it is practical to support both in one driver. But stuff like MDIO and statistics should be possible to share.

Patch 1 adds some register defines and bits that is only found on RM9200.

Patch 2-4 uses the register defines and access functions from the macb header. These can be squashed if it cause too much churn.

Patch 5 merges the private at91_ether struct with the private macb struct. This makes it easier to later share code with the macb. The private macb struct becomes quite large, but most at91_ether specific members are removed in later patches.

Patch 8 make macb compile when we select at91_ether. Is this approach okey?

Patch 9 makes use of MDIO code from macb. This rips out the private phy handling code in at91_ether. One thing that is lost is the interrupt support for phy. But this should easy to add to macb which will then benefit both drivers.

Patch 10 makes use of the macb_set_rx_mode from macb.

Patch 11-12 makes at91_ether share the rx dma struct members from macb. Patch also moves the rx buffer allocation into netdev open and dealloc into netdev close.

Last patch remove the now unused rm9200 emac header from include/mach.


I am going to continue to clean up at91_ether this way if the approach taken in this series is okey.

regards
Joachim Eastwood

Joachim Eastwood (14):
  net/macb: add AT91RM9200 specific registers and bits to header
  net/at91_ether: use macb register definitions
  net/at91_ether: use macb access functions
  net/at91_ether: use macb defs for rx dma buffers
  net/at91_ether/macb: absorb at91_private in to macb private struct
  net/at91_ether: use pclk member instead of ether_clk
  net/macb: export some symbols for at91_ether
  net/at91_ether: compile macb for exported functions
  net/at91_ether: use ethtool and mdio from macb
  net/at91_ether: share macb_set_rx_mode with macb
  net/at91_ether: use macb dma description struct
  net/at91_ether: clean up rx buffer handling
  net/at91_ether: convert to devm_* functions
  ARM: AT91: remove old RM9200 EMAC register definitions

 arch/arm/mach-at91/include/mach/at91rm9200_emac.h |  138 ---
 drivers/net/ethernet/cadence/Kconfig              |    2 +-
 drivers/net/ethernet/cadence/Makefile             |    2 +-
 drivers/net/ethernet/cadence/at91_ether.c         | 1024 ++++-----------------
 drivers/net/ethernet/cadence/at91_ether.h         |  112 ---
 drivers/net/ethernet/cadence/macb.c               |   12 +-
 drivers/net/ethernet/cadence/macb.h               |   22 +
 7 files changed, 207 insertions(+), 1105 deletions(-)
 delete mode 100644 arch/arm/mach-at91/include/mach/at91rm9200_emac.h
 delete mode 100644 drivers/net/ethernet/cadence/at91_ether.h

-- 
1.7.12.2
