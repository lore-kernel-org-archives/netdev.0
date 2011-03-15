From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 15 Mar 2011 10:14:47 +0000
Message-ID: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, plagnioj@jcrosoft.com,
	Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35177 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756996Ab1COKPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 06:15:43 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so389948bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 03:15:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series extends the Atmel MACB driver to support the Cadence
GEM (Gigabit Ethernet MAC) to support 10/100 operation.  The GEM is
based on the MACB block but has a few moved registers and bitfields.
This patch series attempts to use the MACB accessors where block
functionallity is identical and only overrides to GEM specific
acccessors when needed.

This has been runtested on a board with a Cadence GEM and compile tested
for all at91 configurations and a number of avr32 configurations.

Changes since v1:
	- AT91 now provides a fake "hclk" and "macb_clk" has been
	renamed to "pclk" to be consistent with AVR32.
	- Configurable GEM receive buffer size support has been added.
	- pr_foo() and dev_foo() have been converted to netdev_foo()
	where appropriate.
	- New conditional accessors (macb_or_gem_{read,write}l) have
	been introduced that do the conditional accesses dependent on
	macb/gem type.
	- GEM is now dynamically detected from the module ID rather than
	platform device name.

Jean-Christophe, I haven't based this on your conditional clock patch as
I wasn't sure what decision had been made on that and whether the
at91/avr32 detection is reliable.

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

 arch/arm/mach-at91/at572d940hf.c            |    8 +-
 arch/arm/mach-at91/at572d940hf_devices.c    |    6 +-
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
 arch/arm/mach-at91/board-at572d940hf_ek.c   |    2 +-
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
 arch/arm/mach-at91/board-sam9-l9260.c       |    2 +-
 arch/arm/mach-at91/board-sam9260ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9263ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9g20ek.c        |    2 +-
 arch/arm/mach-at91/board-sam9m10g45ek.c     |    2 +-
 arch/arm/mach-at91/board-snapper9260.c      |    2 +-
 arch/arm/mach-at91/board-stamp9g20.c        |    2 +-
 arch/arm/mach-at91/board-usb-a9260.c        |    2 +-
 arch/arm/mach-at91/board-usb-a9263.c        |    2 +-
 arch/arm/mach-at91/board-yl-9200.c          |    2 +-
 arch/arm/mach-at91/include/mach/board.h     |   14 +-
 arch/avr32/mach-at32ap/include/mach/board.h |    5 +-
 drivers/net/Kconfig                         |    8 +-
 drivers/net/macb.c                          |  331 ++++++++++++++++++---------
 drivers/net/macb.h                          |  146 ++++++++++++-
 include/linux/platform_data/macb.h          |   10 +
 50 files changed, 466 insertions(+), 190 deletions(-)
 create mode 100644 include/linux/platform_data/macb.h

-- 
1.7.4

