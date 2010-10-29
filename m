From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA drivers
Date: Thu, 28 Oct 2010 21:19:04 -0400
Message-ID: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33958 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0J2BTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The drivers/net dir has a lot of files - originally there were
no subdirs, but at least now subdirs are being used effectively.
But the original drivers from 10+ years ago are still right
there at the top.  This series creates a drivers/net/legacy dir.

The initial target is things like ISA/EISA/MCA drivers, and with
that alone, we can get close to 90 files out of drivers/net.
Plus, by having a semi-defined description for legacy as being
"drivers more than 10 years old" we'll always have a destination
for drivers as they fall out of maintainership and use.

If in fact this series gets agreement, I'm figuring it makes sense
to have it go in either at the beginning of a dev cycle, or at
the very end -- I have no strict preference; whatever is easier
for people on the whole.  Since I don't expect a lot of activity
in any of these drivers, hopefully it doesn't impact any one else's
pending changes too significantly either way.

All the moves are 100% translation; I didn't add or change any of
the driver sources at all, so I've used "-M" to format the patches
for e-mail.  Similarly, if you apply them and git am nags about
whitespace, that comes directly from the original files.

Paul.

-----

The following changes since commit 19449bfc10d163f0024dd5ae5808e28cda32e7b4:

  stmmac: enable/disable rx/tx in the core with a single write. (2010-10-28 11:47:54 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-2.6.git legacy-netdev

Paul Gortmaker (15):
      net: introduce legacy dir to absorb 10Mbit, ISA, EISA drivers
      3c501: relocate ancient 8 bit ISA driver to legacy dir
      de6xx: relocate ancient parallel port eth drivers to legacy
      sun3: Relocate the sun3 specific lance/83596 drivers to legacy
      dec netdev: relocate DIGITAL based drivers to legacy
      netdev: relocate i8258x and i8259x based drivers to legacy
      lance: relocate legacy 7990 based drivers to legacy
      netdev: relocate toplevel 8390 based drivers to legacy dir
      netdev: relocate remaining ISA 3Com cards to legacy dir
      netdev: relocate more one-off drivers to the legacy dir
      netdev: kill off the concept of NET_VENDOR_FOO
      netdev: relocate sb1000 ISA cable modem driver to legacy
      netdev: kill off NET_ISA Kconfig option
      MAINTAINERS: updates for new drivers/net/legacy dir
      netdev: relocate LICENSE.SRC to legacy

 MAINTAINERS                            |   19 +-
 drivers/net/Kconfig                    |  747 +-------------------------------
 drivers/net/Makefile                   |   63 +---
 drivers/net/arm/etherh.c               |    2 +-
 drivers/net/{ => legacy}/3c501.c       |    0
 drivers/net/{ => legacy}/3c501.h       |    0
 drivers/net/{ => legacy}/3c503.c       |    0
 drivers/net/{ => legacy}/3c503.h       |    0
 drivers/net/{ => legacy}/3c505.c       |    0
 drivers/net/{ => legacy}/3c505.h       |    0
 drivers/net/{ => legacy}/3c507.c       |    0
 drivers/net/{ => legacy}/3c509.c       |    0
 drivers/net/{ => legacy}/3c515.c       |    0
 drivers/net/{ => legacy}/3c523.c       |    0
 drivers/net/{ => legacy}/3c523.h       |    0
 drivers/net/{ => legacy}/3c527.c       |    0
 drivers/net/{ => legacy}/3c527.h       |    0
 drivers/net/{ => legacy}/7990.c        |    0
 drivers/net/{ => legacy}/7990.h        |    0
 drivers/net/{ => legacy}/82596.c       |    0
 drivers/net/{ => legacy}/8390.c        |    0
 drivers/net/{ => legacy}/8390.h        |    0
 drivers/net/{ => legacy}/8390p.c       |    0
 drivers/net/legacy/Kconfig             |  675 +++++++++++++++++++++++++++++
 drivers/net/{ => legacy}/LICENSE.SRC   |    0
 drivers/net/legacy/Makefile            |   78 ++++
 drivers/net/{ => legacy}/ac3200.c      |    0
 drivers/net/{ => legacy}/apne.c        |    0
 drivers/net/{ => legacy}/ariadne.c     |    0
 drivers/net/{ => legacy}/ariadne.h     |    0
 drivers/net/{ => legacy}/at1700.c      |    0
 drivers/net/{ => legacy}/atarilance.c  |    0
 drivers/net/{ => legacy}/ax88796.c     |    0
 drivers/net/{ => legacy}/de600.c       |    0
 drivers/net/{ => legacy}/de600.h       |    0
 drivers/net/{ => legacy}/de620.c       |    0
 drivers/net/{ => legacy}/de620.h       |    0
 drivers/net/{ => legacy}/declance.c    |    0
 drivers/net/{ => legacy}/defxx.c       |    0
 drivers/net/{ => legacy}/defxx.h       |    0
 drivers/net/{ => legacy}/depca.c       |    0
 drivers/net/{ => legacy}/depca.h       |    0
 drivers/net/{ => legacy}/e2100.c       |    0
 drivers/net/{ => legacy}/eepro.c       |    0
 drivers/net/{ => legacy}/eexpress.c    |    0
 drivers/net/{ => legacy}/eexpress.h    |    0
 drivers/net/{ => legacy}/es3210.c      |    0
 drivers/net/{ => legacy}/eth16i.c      |    0
 drivers/net/{ => legacy}/ewrk3.c       |    0
 drivers/net/{ => legacy}/ewrk3.h       |    0
 drivers/net/{ => legacy}/hp-plus.c     |    0
 drivers/net/{ => legacy}/hp.c          |    0
 drivers/net/{ => legacy}/hplance.c     |    0
 drivers/net/{ => legacy}/hplance.h     |    0
 drivers/net/{ => legacy}/hydra.c       |    0
 drivers/net/{ => legacy}/ibmlana.c     |    0
 drivers/net/{ => legacy}/ibmlana.h     |    0
 drivers/net/{ => legacy}/lance.c       |    0
 drivers/net/{ => legacy}/lasi_82596.c  |    0
 drivers/net/{ => legacy}/lib82596.c    |    0
 drivers/net/{ => legacy}/lib8390.c     |    0
 drivers/net/{ => legacy}/lne390.c      |    0
 drivers/net/{ => legacy}/lp486e.c      |    0
 drivers/net/{ => legacy}/mac8390.c     |    0
 drivers/net/{ => legacy}/mvme147.c     |    0
 drivers/net/{ => legacy}/ne-h8300.c    |    0
 drivers/net/{ => legacy}/ne.c          |    0
 drivers/net/{ => legacy}/ne2.c         |    0
 drivers/net/{ => legacy}/ne2k-pci.c    |    0
 drivers/net/{ => legacy}/ne3210.c      |    0
 drivers/net/{ => legacy}/ni5010.c      |    0
 drivers/net/{ => legacy}/ni5010.h      |    0
 drivers/net/{ => legacy}/ni52.c        |    0
 drivers/net/{ => legacy}/ni52.h        |    0
 drivers/net/{ => legacy}/ni65.c        |    0
 drivers/net/{ => legacy}/ni65.h        |    0
 drivers/net/{ => legacy}/sb1000.c      |    0
 drivers/net/{ => legacy}/seeq8005.c    |    0
 drivers/net/{ => legacy}/seeq8005.h    |    0
 drivers/net/{ => legacy}/smc-mca.c     |    0
 drivers/net/{ => legacy}/smc-ultra.c   |    0
 drivers/net/{ => legacy}/smc-ultra32.c |    0
 drivers/net/{ => legacy}/smc9194.c     |    0
 drivers/net/{ => legacy}/smc9194.h     |    0
 drivers/net/{ => legacy}/sni_82596.c   |    0
 drivers/net/{ => legacy}/stnic.c       |    0
 drivers/net/{ => legacy}/sun3_82586.c  |    0
 drivers/net/{ => legacy}/sun3_82586.h  |    0
 drivers/net/{ => legacy}/sun3lance.c   |    0
 drivers/net/{ => legacy}/wd.c          |    0
 drivers/net/{ => legacy}/znet.c        |    0
 drivers/net/{ => legacy}/zorro8390.c   |    0
 drivers/net/pcmcia/axnet_cs.c          |    2 +-
 drivers/net/pcmcia/pcnet_cs.c          |    2 +-
 94 files changed, 782 insertions(+), 806 deletions(-)
 rename drivers/net/{ => legacy}/3c501.c (100%)
 rename drivers/net/{ => legacy}/3c501.h (100%)
 rename drivers/net/{ => legacy}/3c503.c (100%)
 rename drivers/net/{ => legacy}/3c503.h (100%)
 rename drivers/net/{ => legacy}/3c505.c (100%)
 rename drivers/net/{ => legacy}/3c505.h (100%)
 rename drivers/net/{ => legacy}/3c507.c (100%)
 rename drivers/net/{ => legacy}/3c509.c (100%)
 rename drivers/net/{ => legacy}/3c515.c (100%)
 rename drivers/net/{ => legacy}/3c523.c (100%)
 rename drivers/net/{ => legacy}/3c523.h (100%)
 rename drivers/net/{ => legacy}/3c527.c (100%)
 rename drivers/net/{ => legacy}/3c527.h (100%)
 rename drivers/net/{ => legacy}/7990.c (100%)
 rename drivers/net/{ => legacy}/7990.h (100%)
 rename drivers/net/{ => legacy}/82596.c (100%)
 rename drivers/net/{ => legacy}/8390.c (100%)
 rename drivers/net/{ => legacy}/8390.h (100%)
 rename drivers/net/{ => legacy}/8390p.c (100%)
 create mode 100644 drivers/net/legacy/Kconfig
 rename drivers/net/{ => legacy}/LICENSE.SRC (100%)
 create mode 100644 drivers/net/legacy/Makefile
 rename drivers/net/{ => legacy}/ac3200.c (100%)
 rename drivers/net/{ => legacy}/apne.c (100%)
 rename drivers/net/{ => legacy}/ariadne.c (100%)
 rename drivers/net/{ => legacy}/ariadne.h (100%)
 rename drivers/net/{ => legacy}/at1700.c (100%)
 rename drivers/net/{ => legacy}/atarilance.c (100%)
 rename drivers/net/{ => legacy}/ax88796.c (100%)
 rename drivers/net/{ => legacy}/de600.c (100%)
 rename drivers/net/{ => legacy}/de600.h (100%)
 rename drivers/net/{ => legacy}/de620.c (100%)
 rename drivers/net/{ => legacy}/de620.h (100%)
 rename drivers/net/{ => legacy}/declance.c (100%)
 rename drivers/net/{ => legacy}/defxx.c (100%)
 rename drivers/net/{ => legacy}/defxx.h (100%)
 rename drivers/net/{ => legacy}/depca.c (100%)
 rename drivers/net/{ => legacy}/depca.h (100%)
 rename drivers/net/{ => legacy}/e2100.c (100%)
 rename drivers/net/{ => legacy}/eepro.c (100%)
 rename drivers/net/{ => legacy}/eexpress.c (100%)
 rename drivers/net/{ => legacy}/eexpress.h (100%)
 rename drivers/net/{ => legacy}/es3210.c (100%)
 rename drivers/net/{ => legacy}/eth16i.c (100%)
 rename drivers/net/{ => legacy}/ewrk3.c (100%)
 rename drivers/net/{ => legacy}/ewrk3.h (100%)
 rename drivers/net/{ => legacy}/hp-plus.c (100%)
 rename drivers/net/{ => legacy}/hp.c (100%)
 rename drivers/net/{ => legacy}/hplance.c (100%)
 rename drivers/net/{ => legacy}/hplance.h (100%)
 rename drivers/net/{ => legacy}/hydra.c (100%)
 rename drivers/net/{ => legacy}/ibmlana.c (100%)
 rename drivers/net/{ => legacy}/ibmlana.h (100%)
 rename drivers/net/{ => legacy}/lance.c (100%)
 rename drivers/net/{ => legacy}/lasi_82596.c (100%)
 rename drivers/net/{ => legacy}/lib82596.c (100%)
 rename drivers/net/{ => legacy}/lib8390.c (100%)
 rename drivers/net/{ => legacy}/lne390.c (100%)
 rename drivers/net/{ => legacy}/lp486e.c (100%)
 rename drivers/net/{ => legacy}/mac8390.c (100%)
 rename drivers/net/{ => legacy}/mvme147.c (100%)
 rename drivers/net/{ => legacy}/ne-h8300.c (100%)
 rename drivers/net/{ => legacy}/ne.c (100%)
 rename drivers/net/{ => legacy}/ne2.c (100%)
 rename drivers/net/{ => legacy}/ne2k-pci.c (100%)
 rename drivers/net/{ => legacy}/ne3210.c (100%)
 rename drivers/net/{ => legacy}/ni5010.c (100%)
 rename drivers/net/{ => legacy}/ni5010.h (100%)
 rename drivers/net/{ => legacy}/ni52.c (100%)
 rename drivers/net/{ => legacy}/ni52.h (100%)
 rename drivers/net/{ => legacy}/ni65.c (100%)
 rename drivers/net/{ => legacy}/ni65.h (100%)
 rename drivers/net/{ => legacy}/sb1000.c (100%)
 rename drivers/net/{ => legacy}/seeq8005.c (100%)
 rename drivers/net/{ => legacy}/seeq8005.h (100%)
 rename drivers/net/{ => legacy}/smc-mca.c (100%)
 rename drivers/net/{ => legacy}/smc-ultra.c (100%)
 rename drivers/net/{ => legacy}/smc-ultra32.c (100%)
 rename drivers/net/{ => legacy}/smc9194.c (100%)
 rename drivers/net/{ => legacy}/smc9194.h (100%)
 rename drivers/net/{ => legacy}/sni_82596.c (100%)
 rename drivers/net/{ => legacy}/stnic.c (100%)
 rename drivers/net/{ => legacy}/sun3_82586.c (100%)
 rename drivers/net/{ => legacy}/sun3_82586.h (100%)
 rename drivers/net/{ => legacy}/sun3lance.c (100%)
 rename drivers/net/{ => legacy}/wd.c (100%)
 rename drivers/net/{ => legacy}/znet.c (100%)
 rename drivers/net/{ => legacy}/zorro8390.c (100%)
