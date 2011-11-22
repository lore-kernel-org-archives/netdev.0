From: Jamie Iles <jamie@jamieiles.com>
Subject: [GIT PULL] Support for Cadence GEM in the MACB driver (Take 2)
Date: Tue, 22 Nov 2011 15:25:52 +0000
Message-ID: <20111122152552.GA32638@totoro>
References: <20111121100020.GB7314@totoro>
 <20111122100032.GL21480@game.jcrosoft.org>
 <20111122102039.GB8872@totoro>
 <20111122145922.GM21480@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, Arnd Bergmann <arnd@arndb.de>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	davem@davemloft.net,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55161 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab1KVPZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:25:56 -0500
Received: by wwe5 with SMTP id 5so461883wwe.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 07:25:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111122145922.GM21480@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

I've updated the branch with Jean-Christophe's version of the first 
patch which he sent some time ago and I managed to drop.  Apologies all!

Thanks,

Jamie

The following changes since commit cfcfc9eca2bcbd26a8e206baeb005b055dbf8e37:

  Linux 3.2-rc2 (2011-11-15 15:02:59 -0200)

are available in the git repository at:
  git://github.com/jamieiles/linux-2.6-ji.git macb-gem

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

 arch/arm/mach-at91/at91cap9.c               |    4 +-
 arch/arm/mach-at91/at91cap9_devices.c       |    6 +-
 arch/arm/mach-at91/at91rm9200_devices.c     |    6 +-
 arch/arm/mach-at91/at91sam9260.c            |    4 +-
 arch/arm/mach-at91/at91sam9260_devices.c    |    6 +-
 arch/arm/mach-at91/at91sam9263.c            |    4 +-
 arch/arm/mach-at91/at91sam9263_devices.c    |    6 +-
 arch/arm/mach-at91/at91sam9g45.c            |    4 +-
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
 drivers/net/ethernet/Makefile               |    2 +-
 drivers/net/ethernet/cadence/Kconfig        |   16 +-
 drivers/net/ethernet/cadence/at91_ether.c   |    3 +-
 drivers/net/ethernet/cadence/at91_ether.h   |    4 +-
 drivers/net/ethernet/cadence/macb.c         |  344 +++++++++++++++++----------
 drivers/net/ethernet/cadence/macb.h         |  150 ++++++++++++-
 include/linux/platform_data/macb.h          |   17 ++
 57 files changed, 476 insertions(+), 211 deletions(-)
 create mode 100644 include/linux/platform_data/macb.h
