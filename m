From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 09 Dec 2016 23:42:43 -0500 (EST)
Message-ID: <20161209.234243.1628885534479004188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Limit the number of can filters to avoid > MAX_ORDER allocations.
   Fix from Marc Kleine-Budde.

2) Limit GSO max size in netvsc driver to avoid problems with
   NVGRE configurations.  From Stephen Hemminger.

3) Return proper error when memory allocation fails in
   ser_gigaset_init(), from Dan Carpenter.

4) Missing linkage undo in error paths of ipvlan_link_new(), from Gao
   Feng.

5) Missing necessayr SET_NETDEV_DEV in lantiq and cpmac drivers,
   from Florian Fainelli.

6) Handle probe deferral properly in smsc911x driver.

Please pull, thanks a lot!

The following changes since commit bc3913a5378cd0ddefd1dfec6917cc12eb23a946:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc (2016-12-06 09:24:11 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to d33695fbfab73a4a6550fa5c2d0bacc68d7c5901:

  net: mlx5: Fix Kconfig help text (2016-12-09 23:08:32 -0500)

----------------------------------------------------------------
Alex (1):
      drivers: net: cpsw-phy-sel: Clear RGMII_IDMODE on "rgmii" links

Arjun V (1):
      cxgb4/cxgb4vf: Assign netdev->dev_port with port ID

Christopher Covington (1):
      net: mlx5: Fix Kconfig help text

Dan Carpenter (1):
      ser_gigaset: return -ENOMEM on error instead of success

Daniele Palmas (1):
      NET: usb: cdc_mbim: add quirk for supporting Telit LE922A

David S. Miller (3):
      Merge tag 'linux-can-fixes-for-4.9-20161207' of git://git.kernel.org/.../mkl/linux-can
      Merge tag 'linux-can-fixes-for-4.9-20161208' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'ethernet-missing-netdev-parent'

Florian Fainelli (3):
      phy: Don't increment MDIO bus refcount unless it's a different owner
      net: ethernet: lantiq_etop: Call SET_NETDEV_DEV()
      net: ethernet: cpmac: Call SET_NETDEV_DEV()

Gao Feng (1):
      driver: ipvlan: Unlink the upper dev when ipvlan_link_new failed

Linus Walleij (1):
      net: smsc911x: back out silently on probe deferrals

Marc Kleine-Budde (1):
      can: raw: raw_setsockopt: limit number of can_filter that can be set

Peng Tao (1):
      vhost-vsock: fix orphan connection reset

Thomas Falcon (1):
      ibmveth: set correct gso_size and gso_type

stephen hemminger (1):
      netvsc: reduce maximum GSO size

ÃßÁöÈ£ (1):
      can: peak: fix bad memory access and free sequence

 drivers/isdn/gigaset/ser-gigaset.c                  |  4 +++-
 drivers/net/can/usb/peak_usb/pcan_usb_core.c        |  6 ++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c          |  1 -
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c |  1 +
 drivers/net/ethernet/ibm/ibmveth.c                  | 65 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/ibm/ibmveth.h                  |  1 +
 drivers/net/ethernet/lantiq_etop.c                  |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig     |  2 --
 drivers/net/ethernet/smsc/smsc911x.c                |  9 ++++++++-
 drivers/net/ethernet/ti/cpmac.c                     |  1 +
 drivers/net/ethernet/ti/cpsw-phy-sel.c              |  1 +
 drivers/net/hyperv/netvsc_drv.c                     |  5 +++++
 drivers/net/ipvlan/ipvlan_main.c                    |  4 +++-
 drivers/net/phy/phy_device.c                        | 16 +++++++++++++---
 drivers/net/usb/cdc_mbim.c                          | 21 +++++++++++++++++++++
 drivers/net/usb/cdc_ncm.c                           | 14 +++++++++-----
 drivers/vhost/vsock.c                               |  2 +-
 include/linux/usb/cdc_ncm.h                         |  3 ++-
 include/uapi/linux/can.h                            |  1 +
 net/can/raw.c                                       |  3 +++
 21 files changed, 142 insertions(+), 20 deletions(-)
