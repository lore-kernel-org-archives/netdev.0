From: Jeff Garzik <jgarzik@pobox.com>
Subject: netdev-2.6 queue updated
Date: Tue, 27 Jul 2004 15:05:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4106A77D.2070508@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010506040403050403020809"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010506040403050403020809
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Those who are mirroring netdev-2.6 repository, please delete and 
re-clone it.

Attached is a summary of the current contents of the netdev-2.6 queue. 
Several groups of patches are either waiting for the kernel to get out 
of Release Candidate status, or are "simmering"... waiting around for 
additional testing and review.

netdev-2.6 is only available through BitKeeper, or Andrew Morton's -mm 
patches.

	Jeff




--------------010506040403050403020809
Content-Type: text/plain;
 name="changelog.txt"
Content-Disposition: inline;
 filename="changelog.txt"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id i6RJ7IOO024048

BK users may do a

	bk pull bk://gkernel.bkbits.net/netdev-2.6

This will update the following files:

 include/asm-mips/mv64340.h                    | 1039 ----------
 arch/mips/configs/jaguar-atx_defconfig        |    8=20
 arch/mips/configs/ocelot_c_defconfig          |    2=20
 arch/mips/momentum/jaguar_atx/prom.c          |    4=20
 arch/mips/momentum/ocelot_c/prom.c            |    6=20
 drivers/net/8139too.c                         |    4=20
 drivers/net/8390.c                            |   36=20
 drivers/net/8390.h                            |   12=20
 drivers/net/Kconfig                           |   45=20
 drivers/net/Makefile                          |    3=20
 drivers/net/acenic.c                          |  156 -
 drivers/net/acenic.h                          |    2=20
 drivers/net/e100.c                            |   29=20
 drivers/net/eepro100.c                        |   17=20
 drivers/net/epic100.c                         |  426 ++--
 drivers/net/gianfar.c                         | 1921 ++++++++++++++++++
 drivers/net/gianfar.h                         |  537 +++++
 drivers/net/gianfar_ethtool.c                 |  484 ++++
 drivers/net/gianfar_phy.c                     |  504 ++++
 drivers/net/gianfar_phy.h                     |  192 +
 drivers/net/gt64240eth.h                      |  402 +++
 drivers/net/gt96100eth.c                      |  119 -
 drivers/net/mv643xx_eth.c                     | 2646 +++++++++++++++++++=
+++++++
 drivers/net/mv643xx_eth.h                     |  601 +++++
 drivers/net/r8169.c                           |  655 ++++--
 drivers/net/sk98lin/h/skdrv2nd.h              |   54=20
 drivers/net/sk98lin/skaddr.c                  |    4=20
 drivers/net/sk98lin/skge.c                    |  742 +++----
 drivers/net/via-rhine.c                       |  695 +++---
 drivers/net/via-velocity.c                    |  566 ++---
 drivers/net/via-velocity.h                    |    4=20
 drivers/net/wireless/prism54/isl_ioctl.c      |   16=20
 drivers/net/wireless/prism54/islpci_hotplug.c |   17=20
 drivers/net/wireless/prism54/islpci_mgt.c     |    2=20
 drivers/net/wireless/prism54/oid_mgt.c        |    6=20
 include/linux/mv643xx.h                       | 1039 ++++++++++
 include/linux/pci_ids.h                       |    1=20
 37 files changed, 10215 insertions(+), 2781 deletions(-)

through these ChangeSets:

Adrian Bunk:
  o 2.6.8-rc1-mm1: 8139too: uninline rtl8139_start_thread

Andrew Morton:
  o via-velocity warning fixes
  o fix via-velocity oopses

Christoph Hellwig:
  o remove dead code from mv64340_eth
  o fix compiler warnings in mv64340_eth
  o allow modular mv64340_eth
  o convert skge to pci_driver API (2nd try)

Domen Puncer:
  o remove old ifdefs net/eepro100.c

Fran=E7ois Romieu:
  o via-velocity: use common crc16 code for WOL
  o via-velocity: unneeded forward declarations
  o via-velocity: ordering of Rx descriptors operations
  o via-velocity: Rx copybreak
  o via-velocity: Rx buffers allocation rework
  o via-velocity: velocity_receive_frame diets
  o via-velocity: uniformize use of OWNED_BY_NIC
  o via-velocity: PCI ID move
  o r8169: tx lock removal
  o r8169: gcc bug workaround
  o r8169: initial link setup rework
  o r8169: link handling and phy reset rework
  o r8169: ethtool .get_{settings/link}
  o r8169: ethtool .set_settings
  o r8169: janitoring
  o r8169: cosmetic renaming of a register
  o r8169: napi support
  o epic100: code removal in irq handler
  o epic100: spin_unlock_irqrestore avoidance
  o [netdrvr epic100] napi fixes
  o [netdrvr epic100] napi 3/3 - transmit path
  o [netdrvr epic100] napi 2/3 - receive path
  o [netdrvr epic100] napi 1/3 - just shuffle some code around
  o [netdrvr epic100] minor cleanups

Herbert Xu:
  o Fix successive calls to spin_lock_irqsave in sk98lin

Kumar Gala:
  o add new ethernet driver 'gianfar'

Margit Schubert-While:
  o prism54 Fix null pointer reference (Bug 100)
  o prism54 Fix initialization with older firmware
  o prism54 Refix TRDY/RETRY_TIMEOUT
  o prism54 Fix reference to uninitialized pointer

Mika Kukkonen:
  o Fix warnings drivers/net/sk98lin/skaddr.c

Paul Gortmaker:
  o Remove obsolete code in 8390 driver

Ralf B=E4chle:
  o GT96100 update
  o [netdrvr mv643xx] rename from mv64340 to mv643xx
  o New driver for MV64340 GigE

Roger Luethi:
  o Add WOL support
  o Small fixes and clean-up
  o Media mode rewrite
  o Fix Tx engine race for good
  o Remove options, full_duplex parameters
  o Rewrite PHY detection
  o Remove lingering PHY special casing
  o fix mc_filter on big-endian arch
  o Restructure reset code

Scott Feldman:
  o e100: use NAPI mode all the time

Stephen Hemminger:
  o acenic - don't print eth%d in messages
  o module_param for acenic
  o [sparse] minor #if complaint


--------------010506040403050403020809--
