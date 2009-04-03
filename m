From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 02 Apr 2009 17:15:29 -0700 (PDT)
Message-ID: <20090402.171529.174800359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753844AbZDCAPk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 20:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several fixes and small cures, including:

1) Need BH disabling in netfilter RCU sequences, fix from
   Eric Dumazet.  This hit quite a few folks.

2) ixgb/igb bug fixes from the Intel folks via Jeff Kirsher.

3) RDS bug fixes from Andy Grover, including one for the build
   failures on some 32-bit systems.

4) TCP packet counting bug fix from Ilpo J=E4rvinen.

5) HSO bug fixes and device ID additions from Jan Dumon.

6) New VXGE driver from Ramkrishna Vepa.

7) Three request_firmware driver conversions from Jaswinder Singh
   Rajput.

Please pull, thanks a lot!

The following changes since commit 833bb3046b6cb320e775ea2160ddca87d532=
60d5:
  Alexey Dobriyan (1):
        serial: fixup /proc/tty/driver/serial after proc_fops conversio=
n

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Carvalho de Assis (1):
      i.MX31: Fixing cs89x0 network building to i.MX31ADS

Alexander Duyck (6):
      igb: add support for x2 link width configurations
      igb: set num_rx/tx_queues to 0 when queues are freed
      igb: increase delay for copper link setup
      igb: cleanup igb loopback path
      ixgbe: fix build when DEBUG is defined
      ixgbe: refactor tx buffer processing to use skb_dma_map/unmap

Andy Grover (3):
      RDS: Fix m_rs_lock deadlock
      RDS: Rewrite connection cleanup, fixing oops on rmmod
      RDS: Use spinlock to protect 64b value update on 32b archs

Anton Vorontsov (2):
      ucc_geth: Pass proper device to DMA routines, otherwise oops happ=
ens
      fsl_pq_mdio: Revive UCC MDIO support

Atsushi Nemoto (1):
      tc35815: Fix build error if NAPI enabled

Ben Hutchings (1):
      sfc: Call netif_napi_add() before registering our interrupt handl=
er

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../jaswinder/net-n=
ext-2.6

Don Skidmore (3):
      ixgbe: Fix ethtool output with advertised mode.
      ixgbe: feature - driver to default with FC on.
      ixgbe: fix ethtool -A|a behavior

Eric Dumazet (1):
      netfilter: use rcu_read_bh() in ipt_do_table()

Grant Likely (2):
      net/fec_mpc52xx: fix BUG on missing dma_ops
      net/fec_mpc52xx: Don't dereference phy_device if it is NULL

Heiko Carstens (1):
      ETHOC: fix build breakage on s390

Henk Stegeman (1):
      net/fec_mpc52xx: Migrate to net_device_ops.

Huang Weiyi (2):
      dnet: remove unused #include <version.h>
      glge: remove unused #include <version.h>

Ilpo J=E4rvinen (2):
      tcp: add helper for counter tweaking due mid-wq change
      tcp: miscounts due to tcp_fragment pcount reset

Jan Dumon (3):
      hso: add Vendor/Product ID's for new devices
      hso: fix for crash when unplugging the device
      hso: fix for the 'invalid frame length' messages

Jaswinder Singh Rajput (3):
      yam: use request_firmware
      3C359: use request_firmware
      smc91c92_cs: use request_firmware

Karsten Wiese (1):
      r8169: reset IntrStatus after chip reset

Kumar Gala (2):
      gianfar: Remove unused header
      ucc_geth: Remove unused header

Larry Finger (1):
      kaweth: Fix locking to be SMP-safe

Mallikarjuna R Chilakala (2):
      ixgbe: Patch to fix driver panic while freeing up tx & rx resourc=
es
      ixgbe: Fix potential memory leak/driver panic issue while setting=
 up Tx & Rx ring parameters

PJ Waskiewicz (2):
      ixgbe: Fix DCB netlink layer for 82599 to enable Priority Flow Co=
ntrol
      ixgbe: Fix 82598 MSI-X allocation on systems with more than 8 CPU=
 cores

Rafael J. Wysocki (1):
      net/igb: Fix kexec with igb (rev. 3)

Rami Rosen (1):
      ipv4: remove unused parameter from tcp_recv_urg().

Ramkrishna Vepa (9):
      Neterion: Driver help file
      Neterion: New driver: Update Maintainer list
      Neterion: New driver: register set - vxge-reg.h
      Neterion: New driver: Hardware init & configuration
      Neterion: New driver: Traffic & alarm handler
      Neterion: New driver: Main entry points
      Neterion: New driver: Ethtool related
      Neterion: New driver: Driver version
      Neterion: New driver: Kconfig and Makefile

Segher Boessenkool (1):
      fsl_pq_mdio: Fix compile failure

Stephen Hemminger (1):
      net: allow multiple dev per napi with GRO

Wei Yongjun (1):
      core: remove pointless conditional before kfree()

 Documentation/networking/vxge.txt       |  100 +
 MAINTAINERS                             |    7 +-
 drivers/net/Kconfig                     |   19 +-
 drivers/net/Makefile                    |    1 +
 drivers/net/dnet.c                      |    1 -
 drivers/net/fec_mpc52xx.c               |   77 +-
 drivers/net/fsl_pq_mdio.c               |    3 +-
 drivers/net/gianfar.h                   |    1 -
 drivers/net/hamradio/yam.c              |   64 +-
 drivers/net/hamradio/yam1200.h          |  343 --
 drivers/net/hamradio/yam9600.h          |  343 --
 drivers/net/igb/e1000_phy.c             |    7 +-
 drivers/net/igb/igb_ethtool.c           |   14 +-
 drivers/net/igb/igb_main.c              |   54 +-
 drivers/net/ixgbe/ixgbe_82598.c         |    3 +-
 drivers/net/ixgbe/ixgbe_common.c        |    3 +-
 drivers/net/ixgbe/ixgbe_common.h        |    9 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c        |    6 +-
 drivers/net/ixgbe/ixgbe_ethtool.c       |  129 +-
 drivers/net/ixgbe/ixgbe_main.c          |  110 +-
 drivers/net/ixgbe/ixgbe_type.h          |    1 +
 drivers/net/pcmcia/ositech.h            |  358 ---
 drivers/net/pcmcia/smc91c92_cs.c        |   44 +-
 drivers/net/qlge/qlge_ethtool.c         |    1 -
 drivers/net/r8169.c                     |    5 +-
 drivers/net/sfc/efx.c                   |    7 +-
 drivers/net/tc35815.c                   |    2 +-
 drivers/net/tokenring/3c359.c           |   63 +-
 drivers/net/tokenring/3c359.h           |    3 +
 drivers/net/tokenring/3c359_microcode.h | 1581 ----------
 drivers/net/ucc_geth.c                  |   22 +-
 drivers/net/ucc_geth.h                  |    4 +-
 drivers/net/ucc_geth_ethtool.c          |    1 -
 drivers/net/usb/hso.c                   |   40 +-
 drivers/net/usb/kaweth.c                |    7 +-
 drivers/net/vxge/Makefile               |    7 +
 drivers/net/vxge/vxge-config.c          | 5264 +++++++++++++++++++++++=
++++++++
 drivers/net/vxge/vxge-config.h          | 2259 +++++++++++++
 drivers/net/vxge/vxge-ethtool.c         | 1148 +++++++
 drivers/net/vxge/vxge-ethtool.h         |   67 +
 drivers/net/vxge/vxge-main.c            | 4502 +++++++++++++++++++++++=
+++
 drivers/net/vxge/vxge-main.h            |  557 ++++
 drivers/net/vxge/vxge-reg.h             | 4608 +++++++++++++++++++++++=
++++
 drivers/net/vxge/vxge-traffic.c         | 2528 +++++++++++++++
 drivers/net/vxge/vxge-traffic.h         | 2409 ++++++++++++++
 drivers/net/vxge/vxge-version.h         |   23 +
 firmware/3com/3C359.bin.ihex            | 1573 +++++++++
 firmware/Makefile                       |    3 +
 firmware/WHENCE                         |   50 +
 firmware/ositech/Xilinx7OD.bin.ihex     |  177 ++
 firmware/yam/1200.bin.ihex              |  342 ++
 firmware/yam/9600.bin.ihex              |  342 ++
 include/net/tcp.h                       |   15 -
 net/core/dev.c                          |    5 +-
 net/core/ethtool.c                      |    3 +-
 net/ipv4/netfilter/arp_tables.c         |    4 +-
 net/ipv4/netfilter/ip_tables.c          |    4 +-
 net/ipv4/tcp.c                          |    5 +-
 net/ipv4/tcp_output.c                   |   73 +-
 net/ipv6/netfilter/ip6_tables.c         |    4 +-
 net/rds/ib.c                            |    5 +-
 net/rds/ib.h                            |   28 +-
 net/rds/ib_cm.c                         |   43 +-
 net/rds/ib_rdma.c                       |   43 +-
 net/rds/ib_recv.c                       |   37 +-
 net/rds/iw.c                            |    5 +-
 net/rds/iw.h                            |   28 +-
 net/rds/iw_cm.c                         |   44 +-
 net/rds/iw_rdma.c                       |   44 +-
 net/rds/iw_recv.c                       |   37 +-
 net/rds/rds.h                           |    4 +
 net/rds/send.c                          |    6 +-
 72 files changed, 26689 insertions(+), 3040 deletions(-)
 create mode 100644 Documentation/networking/vxge.txt
 delete mode 100644 drivers/net/hamradio/yam1200.h
 delete mode 100644 drivers/net/hamradio/yam9600.h
 delete mode 100644 drivers/net/pcmcia/ositech.h
 delete mode 100644 drivers/net/tokenring/3c359_microcode.h
 create mode 100644 drivers/net/vxge/Makefile
 create mode 100644 drivers/net/vxge/vxge-config.c
 create mode 100644 drivers/net/vxge/vxge-config.h
 create mode 100644 drivers/net/vxge/vxge-ethtool.c
 create mode 100644 drivers/net/vxge/vxge-ethtool.h
 create mode 100644 drivers/net/vxge/vxge-main.c
 create mode 100644 drivers/net/vxge/vxge-main.h
 create mode 100644 drivers/net/vxge/vxge-reg.h
 create mode 100644 drivers/net/vxge/vxge-traffic.c
 create mode 100644 drivers/net/vxge/vxge-traffic.h
 create mode 100644 drivers/net/vxge/vxge-version.h
 create mode 100644 firmware/3com/3C359.bin.ihex
 create mode 100644 firmware/ositech/Xilinx7OD.bin.ihex
 create mode 100644 firmware/yam/1200.bin.ihex
 create mode 100644 firmware/yam/9600.bin.ihex
