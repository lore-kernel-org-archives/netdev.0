From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv4 0/9] macb: add support for Cadence GEM
Date: Tue,  8 Nov 2011 14:13:24 +0000
Message-ID: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
Cc: arnd@arndb.de, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63521 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab1KHONn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:13:43 -0500
Received: by wyh15 with SMTP id 15so512103wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:13:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've rebased these patches onto v3.2-rc1 to include the Ethernet driver
moves and the addition of a couple of new AT91 boards but otherwise this
is the same series as before.

If we can get these into next then that would be great (I can publish
these to a branch for a pull request I guess through the arm-soc tree?).

Jamie Iles (9):
  at91: provide macb clks with "pclk" and "hclk" name
  macb: remove conditional clk handling
  macb: unify at91 and avr32 platform data
  macb: convert printk to netdev_ and friends
  macb: initial support for Cadence GEM
  macb: support higher rate GEM MDIO clock divisors
  macb: support statistics for GEM devices
  macb: support DMA bus widths > 32 bits
  macb: allow GEM to have configurable receive buffer size

 arch/arm/mach-at91/at91cap9.c               |    8 +-
 arch/arm/mach-at91/at91cap9_devices.c       |    6 +-
 arch/arm/mach-at91/at91rm9200_devices.c     |    6 +-
 arch/arm/mach-at91/at91sam9260.c            |    8 +-
 arch/arm/mach-at91/at91sam9260_devices.c    |    6 +-
 arch/arm/mach-at91/at91sam9263.c            |    8 +-
 arch/arm/mach-at91/at91sam9263_devices.c    |    6 +-
 arch/arm/mach-at91/at91sam9g45.c            |    8 +-
 arch/arm/mach-at91/at91sam9g45_devices.c    |    6 +-
 arch/arm/mach-at91/board-1arm.c             |    2 +-
 arch/arm/mach-at91/board-afeb-9260v1.c      |    2 +-
 arch/arm/mach-at91/board-cam60.c            |    2 +-
 arch/arm/mach-at91/board-cap9adk.c          |    2 +-
 arch/arm/mach-at91/board-carmeva.c          |    2 +-
 arch/arm/mach-at91/board-cpu9krea.c         |    2 +-
 arch/arm/mach-at91/board-cpuat91.c          |    2 +-
 arch/arm/mach-at91/board-csb337.c           |    2 +-
 arch/arm/mach-at91/board-csb637.c           |    2 +-
 arch/arm/mach-at91/board-eb9200.c           |    2 +-
 arch/arm/mach-at91/board-ecbat91.c          |    2 +-
 arch/arm/mach-at91/board-eco920.c           |    2 +-
 arch/arm/mach-at91/board-foxg20.c           |    2 +-
 arch/arm/mach-at91/board-gsia18s.c          |    2 +-
 arch/arm/mach-at91/board-kafa.c             |    2 +-
 arch/arm/mach-at91/board-kb9202.c           |    2 +-
 arch/arm/mach-at91/board-neocore926.c       |    2 +-
 arch/arm/mach-at91/board-pcontrol-g20.c     |    2 +-
 arch/arm/mach-at91/board-picotux200.c       |    2 +-
 arch/arm/mach-at91/board-qil-a9260.c        |    2 +-
 arch/arm/mach-at91/board-rm9200dk.c         |    2 +-
 arch/arm/mach-at91/board-rm9200ek.c         |    2 +-
 arch/arm/mach-at91/board-rsi-ews.c          |    2 +-
 arch/arm/mach-at91/board-sam9-l9260.c       |    2 +-
 arch/arm/mach-at91/board-sam9260ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9263ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9g20ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9m10g45ek.c     |    2 +-
 arch/arm/mach-at91/board-snapper9260.c      |    2 +-
 arch/arm/mach-at91/board-stamp9g20.c        |    2 +-
 arch/arm/mach-at91/board-usb-a926x.c        |    2 +-
 arch/arm/mach-at91/board-yl-9200.c          |    2 +-
 arch/arm/mach-at91/include/mach/board.h     |   14 +-
 arch/avr32/boards/atngw100/setup.c          |    2 +-
 arch/avr32/boards/atstk1000/atstk1002.c     |    2 +-
 arch/avr32/boards/favr-32/setup.c           |    2 +-
 arch/avr32/boards/hammerhead/setup.c        |    2 +-
 arch/avr32/boards/merisc/setup.c            |    2 +-
 arch/avr32/boards/mimc200/setup.c           |    2 +-
 arch/avr32/mach-at32ap/at32ap700x.c         |    8 +-
 arch/avr32/mach-at32ap/include/mach/board.h |    7 +-
 drivers/net/ethernet/cadence/Kconfig        |   16 +-
 drivers/net/ethernet/cadence/at91_ether.c   |    3 +-
 drivers/net/ethernet/cadence/at91_ether.h   |    4 +-
 drivers/net/ethernet/cadence/macb.c         |  338 +++++++++++++++++----------
 drivers/net/ethernet/cadence/macb.h         |  150 ++++++++++++-
 include/linux/platform_data/macb.h          |   17 ++
 56 files changed, 489 insertions(+), 206 deletions(-)
 create mode 100644 include/linux/platform_data/macb.h

-- 
1.7.4.1
