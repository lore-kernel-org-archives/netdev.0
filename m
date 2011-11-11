From: ddaney.cavm@gmail.com
Subject: [PATCH 0/3] Move some Octeon support files out of staging.
Date: Thu, 10 Nov 2011 16:29:44 -0800
Message-ID: <1320971387-29343-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de, devel@driverdev.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54652 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755695Ab1KKA3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 19:29:54 -0500
Received: by yenr9 with SMTP id r9so2595279yen.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 16:29:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

First patch:

In preparation for my next set of patches to add device tree support
for Octeon, move some files out of drivers/staging/octeon to common
location.  There are two basic types of files I am moving:

1) Register definition files.  Most Octeon register definition files
   are in arch/mips/include/asm/octeon, put the rest there too.

2) Low level packet port type probing code.  This is needed by both
   the Ethernet driver and the code that fixes up the in-kernel device
   trees.  Although new board pass a device tree to the kernel,
   support of legacy boards requires that this probing code be used to
   fix up an in-kernel device tree template.


Second patch:

Update support for legacy boards.


Third patch:

Seperate probing and initialization of packet ports.


Since these are MIPS architecture files we could merge via Ralf's tree
if approved.

David Daney (3):
  MIPS: Octeon: Move some Ethernet support files out of staging.
  MIPS: Octeon: Update bootloader board type constants.
  MIPS: Octeon: Rearrange CVMX files in preperation for device tree

 arch/mips/cavium-octeon/executive/Makefile         |    5 +
 .../mips/cavium-octeon/executive}/cvmx-cmd-queue.c |    8 +-
 .../mips/cavium-octeon/executive}/cvmx-fpa.c       |    0
 .../cavium-octeon/executive}/cvmx-helper-board.c   |   38 +++--
 .../cavium-octeon/executive}/cvmx-helper-fpa.c     |    0
 .../cavium-octeon/executive}/cvmx-helper-loop.c    |    6 +-
 .../cavium-octeon/executive}/cvmx-helper-npi.c     |    6 +-
 .../cavium-octeon/executive}/cvmx-helper-rgmii.c   |   17 +-
 .../cavium-octeon/executive}/cvmx-helper-sgmii.c   |   18 ++-
 .../cavium-octeon/executive}/cvmx-helper-spi.c     |   20 ++-
 .../cavium-octeon/executive}/cvmx-helper-util.c    |   16 +-
 .../cavium-octeon/executive}/cvmx-helper-xaui.c    |   32 ++--
 .../mips/cavium-octeon/executive}/cvmx-helper.c    |  120 ++++++++++----
 .../executive}/cvmx-interrupt-decodes.c            |   10 +-
 .../cavium-octeon/executive}/cvmx-interrupt-rsl.c  |    4 +-
 .../mips/cavium-octeon/executive}/cvmx-pko.c       |    8 +-
 .../mips/cavium-octeon/executive}/cvmx-spi.c       |   12 +-
 .../mips/include/asm}/octeon/cvmx-address.h        |    0
 .../mips/include/asm}/octeon/cvmx-asxx-defs.h      |    0
 arch/mips/include/asm/octeon/cvmx-bootinfo.h       |   72 ++++++++-
 .../mips/include/asm}/octeon/cvmx-cmd-queue.h      |    0
 .../mips/include/asm}/octeon/cvmx-config.h         |    0
 .../mips/include/asm}/octeon/cvmx-dbg-defs.h       |    0
 .../mips/include/asm}/octeon/cvmx-fau.h            |    0
 .../mips/include/asm}/octeon/cvmx-fpa-defs.h       |    0
 .../mips/include/asm}/octeon/cvmx-fpa.h            |    0
 .../mips/include/asm}/octeon/cvmx-gmxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-helper-board.h   |    6 +
 .../mips/include/asm}/octeon/cvmx-helper-fpa.h     |    0
 .../mips/include/asm}/octeon/cvmx-helper-loop.h    |    1 +
 .../mips/include/asm}/octeon/cvmx-helper-npi.h     |    1 +
 .../mips/include/asm}/octeon/cvmx-helper-rgmii.h   |    1 +
 .../mips/include/asm}/octeon/cvmx-helper-sgmii.h   |    1 +
 .../mips/include/asm}/octeon/cvmx-helper-spi.h     |    1 +
 .../mips/include/asm}/octeon/cvmx-helper-util.h    |    0
 .../mips/include/asm}/octeon/cvmx-helper-xaui.h    |    1 +
 .../mips/include/asm}/octeon/cvmx-helper.h         |    1 +
 .../mips/include/asm}/octeon/cvmx-ipd.h            |    0
 .../mips/include/asm}/octeon/cvmx-mdio.h           |    0
 .../mips/include/asm}/octeon/cvmx-pcsx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-pcsxx-defs.h     |    0
 .../mips/include/asm}/octeon/cvmx-pip-defs.h       |    0
 .../mips/include/asm}/octeon/cvmx-pip.h            |    0
 .../mips/include/asm}/octeon/cvmx-pko-defs.h       |    0
 .../mips/include/asm}/octeon/cvmx-pko.h            |    0
 .../mips/include/asm}/octeon/cvmx-pow.h            |    0
 .../mips/include/asm}/octeon/cvmx-scratch.h        |    0
 .../mips/include/asm}/octeon/cvmx-spi.h            |    0
 .../mips/include/asm}/octeon/cvmx-spxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-srxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-stxx-defs.h      |    0
 .../mips/include/asm}/octeon/cvmx-wqe.h            |    0
 drivers/staging/octeon/Makefile                    |    5 -
 drivers/staging/octeon/cvmx-packet.h               |   65 -------
 drivers/staging/octeon/cvmx-smix-defs.h            |  178 --------------------
 drivers/staging/octeon/ethernet-defines.h          |    2 +-
 drivers/staging/octeon/ethernet-mdio.c             |    4 +-
 drivers/staging/octeon/ethernet-mem.c              |    2 +-
 drivers/staging/octeon/ethernet-rgmii.c            |    4 +-
 drivers/staging/octeon/ethernet-rx.c               |   14 +-
 drivers/staging/octeon/ethernet-rx.h               |    2 +-
 drivers/staging/octeon/ethernet-sgmii.c            |    4 +-
 drivers/staging/octeon/ethernet-spi.c              |    6 +-
 drivers/staging/octeon/ethernet-tx.c               |   12 +-
 drivers/staging/octeon/ethernet-xaui.c             |    4 +-
 drivers/staging/octeon/ethernet.c                  |   14 +-
 66 files changed, 326 insertions(+), 395 deletions(-)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-cmd-queue.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-fpa.c (100%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-board.c (96%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-fpa.c (100%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-loop.c (95%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-npi.c (96%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-rgmii.c (97%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-sgmii.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-spi.c (94%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-util.c (97%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper-xaui.c (97%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-helper.c (93%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-interrupt-decodes.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-interrupt-rsl.c (97%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-pko.c (98%)
 rename {drivers/staging/octeon => arch/mips/cavium-octeon/executive}/cvmx-spi.c (99%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-address.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-asxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-cmd-queue.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-config.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-dbg-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-fau.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-fpa-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-fpa.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-gmxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-board.h (96%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-fpa.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-loop.h (96%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-npi.h (96%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-rgmii.h (98%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-sgmii.h (98%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-spi.h (98%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-util.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper-xaui.h (98%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-helper.h (99%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-ipd.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-mdio.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pcsx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pcsxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pip-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pip.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pko-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pko.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-pow.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-scratch.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-spi.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-spxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-srxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-stxx-defs.h (100%)
 rename {drivers/staging => arch/mips/include/asm}/octeon/cvmx-wqe.h (100%)
 delete mode 100644 drivers/staging/octeon/cvmx-packet.h
 delete mode 100644 drivers/staging/octeon/cvmx-smix-defs.h

-- 
1.7.2.3
