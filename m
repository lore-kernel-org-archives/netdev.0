From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 0/8] macb: add support for Cadence GEM
Date: Thu, 10 Mar 2011 10:10:35 +0000
Message-ID: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42407 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158Ab1CJKKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 05:10:49 -0500
Received: by wwa36 with SMTP id 36so1752924wwa.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 02:10:48 -0800 (PST)
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

Jamie Iles (8):
  macb: unify at91 and avr32 platform data
  macb: detect hclk presence from platform data
  macb: convert printk to pr_ and friends
  macb: initial support for Cadence GEM
  macb: handle HW address registers for GEM devices
  macb: support higher rate GEM MDIO clock divisors
  macb: support statistics for GEM devices
  macb: support data bus widths > 32 bits

 arch/arm/mach-at91/at572d940hf_devices.c    |    6 +-
 arch/arm/mach-at91/at91cap9_devices.c       |    6 +-
 arch/arm/mach-at91/at91rm9200_devices.c     |    6 +-
 arch/arm/mach-at91/at91sam9260_devices.c    |    6 +-
 arch/arm/mach-at91/at91sam9263_devices.c    |    6 +-
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
 arch/avr32/mach-at32ap/at32ap700x.c         |    2 +
 arch/avr32/mach-at32ap/include/mach/board.h |    5 +-
 drivers/net/Kconfig                         |    8 +-
 drivers/net/macb.c                          |  294 +++++++++++++++++++--------
 drivers/net/macb.h                          |   90 ++++++++-
 include/linux/platform_data/macb.h          |   17 ++
 46 files changed, 381 insertions(+), 151 deletions(-)
 create mode 100644 include/linux/platform_data/macb.h

-- 
1.7.4

