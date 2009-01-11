From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 11 Jan 2009 04:14:15 -0800 (PST)
Message-ID: <20090111.041415.93451831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751367AbZAKMOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 07:14:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) IRDA build fix from Alexander Beregalov.

2) DCCP section mismatch fix.

3) Several cures sent to me via Andrew Morton a few days ago.

4) Wake on lan fix for 3c59x from Steffen Klassert.

5) R6040 driver fixes from Florian Fainelli.

6) Several forcedeth driver bug fixes from Ayaz Abdulla.

7) qlge driver fixes from Ron Mercer.

8) Fixes for net_dev_ops conversions from Stephen Hemminger.

9) smc911x bug fixes from Steve Glendinning.

Please pull, thanks a lot!

The following changes since commit c59765042f53a79a7a65585042ff463b69cb248c:
  Linus Torvalds (1):
        Linux 2.6.29-rc1

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Beregalov (1):
      irda: fix incomplete conversation to internal stats

Ayaz Abdulla (4):
      forcedeth: xmit lock fix
      forcedeth: version bump and copyright
      forcedeth: remove mgmt unit for mcp79 chipset
      forcedeth: napi schedule lock fix

Ben Hutchings (1):
      sfc: SFT9001: Fix condition for LNPGA power-off

Clifford Wolf (1):
      netdev: gianfar: add MII ioctl handler

Dan Williams (1):
      net_dma: acquire/release dma channels on ifup/ifdown

David Graham (1):
      e1000e: Add process name to WARN message when detecting Mutex contention

Felix Fietkau (1):
      b44: fix misalignment and wasted space in rx handling

Florian Fainelli (4):
      r6040: fix ifconfig down and freeing of tx/rx descriptors
      r6040: generate random ethernet MAC address when not initialized
      r6040: no longer mark r6040 as being experimental
      r6040: bump release to 0.21

Frank Blaschka (1):
      qeth: fix usage of netdev_ops

Gerrit Renker (1):
      dccp ccid-3: Fix RFC reference

Herbert Xu (1):
      ipcomp: Remove spurious truesize increase

Inaky Perez-Gonzalez (1):
      wimax: fix typo in kernel-doc for debugfs_dentry in struct wimax_dev

Jesper Dangaard Brouer (1):
      qlge: Naming interrupt vectors

Julia Lawall (5):
      net/tipc/bcast.h: use ARRAY_SIZE
      net/bridge/netfilter: move a dereference below a NULL test
      drivers/isdn/hardware/mISDN: move a dereference below a NULL test
      drivers/net/hamradio/6pack.c: move a dereference below a NULL test
      drivers/net/wireless/libertas: move a dereference below a NULL test

Leonardo Potenza (1):
      net: fix section mismatch warnings in dccp/ccids/lib/tfrc.c

Roland Dreier (1):
      cxgb3: Keep LRO off if disabled when interface is down

Ron Mercer (5):
      qlge: Get rid of volatile usage for shadow register.
      qlge: Get rid of split addresses in hardware control blocks.
      qlge: Remove support for device ID 8000.
      qlge: Fix schedule while atomic issue.
      qlge: Remove dynamic alloc of rx ring control blocks.

Steffen Klassert (1):
      3c59x: Use device_set_wakeup_enable

Stephen Hemminger (2):
      netdev: add missing set_mac_address hook
      netdev: missing validate_address hooks

Steve Glendinning (2):
      smsc911x: fix smsc911x_reg_read compiler warning
      smsc911x: register irq with device name, not driver name

Timur Tabi (1):
      ucc_geth: use correct UCCE macros

 drivers/isdn/hardware/mISDN/hfcmulti.c |    3 +-
 drivers/net/3c503.c                    |    1 +
 drivers/net/3c59x.c                    |    2 +
 drivers/net/8139cp.c                   |    2 +
 drivers/net/8139too.c                  |    2 +-
 drivers/net/8390.c                     |    1 +
 drivers/net/8390p.c                    |    1 +
 drivers/net/Kconfig                    |    2 +-
 drivers/net/acenic.c                   |    1 +
 drivers/net/arm/etherh.c               |    1 +
 drivers/net/arm/ks8695net.c            |    1 +
 drivers/net/b44.c                      |   13 ++--
 drivers/net/cxgb3/adapter.h            |    7 ++-
 drivers/net/cxgb3/cxgb3_main.c         |   22 ++++--
 drivers/net/cxgb3/sge.c                |    2 +-
 drivers/net/e1000e/ich8lan.c           |   19 +++--
 drivers/net/e2100.c                    |    1 +
 drivers/net/enic/enic_main.c           |    1 +
 drivers/net/forcedeth.c                |   22 +++---
 drivers/net/gianfar.c                  |   15 ++++
 drivers/net/hamachi.c                  |    1 +
 drivers/net/hamradio/6pack.c           |    3 +-
 drivers/net/hp-plus.c                  |    1 +
 drivers/net/hydra.c                    |    1 +
 drivers/net/irda/au1k_ir.c             |    2 +-
 drivers/net/irda/donauboe.c            |    8 +-
 drivers/net/mac8390.c                  |    1 +
 drivers/net/mlx4/en_netdev.c           |    1 +
 drivers/net/ne-h8300.c                 |    1 +
 drivers/net/ne2k-pci.c                 |    1 +
 drivers/net/ns83820.c                  |    1 +
 drivers/net/qlge/qlge.h                |   61 +++++++++------
 drivers/net/qlge/qlge_dbg.c            |   62 ++++++----------
 drivers/net/qlge/qlge_main.c           |   80 +++++---------------
 drivers/net/r6040.c                    |   43 +++++++----
 drivers/net/sc92031.c                  |    1 +
 drivers/net/sfc/tenxpress.c            |    5 +-
 drivers/net/sis900.c                   |    1 +
 drivers/net/smc-mca.c                  |    1 +
 drivers/net/smc-ultra.c                |    1 +
 drivers/net/smsc911x.c                 |    4 +-
 drivers/net/smsc9420.c                 |    1 +
 drivers/net/ucc_geth.c                 |  128 +++++++++++---------------------
 drivers/net/ucc_geth.h                 |  114 ++++++----------------------
 drivers/net/via-rhine.c                |    1 +
 drivers/net/via-velocity.c             |    1 +
 drivers/net/wd.c                       |    1 +
 drivers/net/wireless/libertas/main.c   |    7 +-
 drivers/net/yellowfin.c                |    1 +
 drivers/net/zorro8390.c                |    1 +
 drivers/s390/net/qeth_l2_main.c        |    2 +-
 drivers/s390/net/qeth_l3_main.c        |   24 +++++-
 include/linux/dmaengine.h              |   10 +++
 include/net/wimax.h                    |    4 +-
 net/bridge/netfilter/ebtables.c        |    3 +-
 net/core/dev.c                         |   13 +++-
 net/dccp/ccids/Kconfig                 |    2 +-
 net/dccp/ccids/lib/tfrc.c              |    2 +-
 net/tipc/bcast.h                       |    2 +-
 net/xfrm/xfrm_ipcomp.c                 |    1 -
 60 files changed, 344 insertions(+), 373 deletions(-)
