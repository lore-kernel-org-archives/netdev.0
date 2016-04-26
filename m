From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 26 Apr 2016 17:58:52 -0400 (EDT)
Message-ID: <20160426.175852.716762237890094028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Handle v4/v6 mixed sockets properly in soreuseport, from Craig Gallak.

2) Bug fixes for the new macsec facility (missing kmalloc NULL checks,
   missing locking around netdev list traversal, etc.) from Sabrina
   Dubroca.

3) Fix handling of host routes on ifdown in ipv6, from David Ahern.

4) Fix double-fdput in bpf verifier.  From Jann Horn.

Please pull, thanks a lot!

The following changes since commit 5f44abd041c5f3be76d57579ab254d78e601315b:

  Merge tag 'rtc-4.6-3' of git://git.kernel.org/pub/scm/linux/kernel/git/abelloni/linux (2016-04-21 15:41:13 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 8358b02bf67d3a5d8a825070e1aa73f25fb2e4c7:

  bpf: fix double-fdput in replace_map_fd_with_map_ptr() (2016-04-26 17:37:21 -0400)

----------------------------------------------------------------
David Ahern (1):
      net: ipv6: Delete host routes on an ifdown

David S. Miller (5):
      Merge branch 'bridge-mdb-fixes'
      Merge branch 'macsec-fixes'
      Merge branch 'mlx5-fixes'
      ipv6: Revert optional address flusing on ifdown.
      Revert "ipv6: Revert optional address flusing on ifdown."

Elad Raz (3):
      switchdev: Adding complete operation to deferred switchdev ops
      bridge: mdb: Common function for mdb entry translation
      bridge: mdb: Marking port-group as offloaded

Eli Cohen (1):
      net/mlx5_core: Remove static from local variable

Eric Dumazet (1):
      net/mlx4_en: fix spurious timestamping callbacks

Grygorii Strashko (1):
      MAINTAINERS: net: add entry for TI Ethernet Switch drivers

Ivan Babrou (1):
      net: dummy: remove note about being Y by default

Jann Horn (1):
      bpf: fix double-fdput in replace_map_fd_with_map_ptr()

Jiri Benc (1):
      cxgbi: fix uninitialized flowi6

Majd Dibbiny (2):
      net/mlx5_core: Add ConnectX-5 to list of supported devices
      net/mlx5: Add pci shutdown callback

Manish Chopra (1):
      qlcnic: Update version to 5.3.64

Maor Gottlieb (1):
      net/mlx5_core: Fix soft lockup in steering error flow

Marek Vasut (1):
      net: stmmac: socfpga: Remove re-registration of reset controller

Paolo Abeni (1):
      ipv4/fib: don't warn when primary address is missing if in_dev is dead

Rana Shahout (1):
      net/mlx5e: Fix MLX5E_100BASE_T define

Sabrina Dubroca (9):
      macsec: add missing NULL check after kmalloc
      macsec: take rtnl lock before for_each_netdev
      macsec: don't put a NULL rxsa
      macsec: fix rx_sa refcounting with decrypt callback
      macsec: add consistency check to netlink dumps
      macsec: fix memory leaks around rx_handler (un)registration
      macsec: fix SA leak if initialization fails
      macsec: add missing macsec prefix in uapi
      macsec: fix netlink attribute validation

Saeed Mahameed (3):
      net/mlx5e: Device's mtu field is u16 and not int
      net/mlx5e: Fix minimum MTU
      net/mlx5e: Use vport MTU rather than physical port MTU

 MAINTAINERS                                          |   9 +++++
 drivers/infiniband/hw/mlx5/main.c                    |   4 +--
 drivers/net/Kconfig                                  |   5 ++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c           |   6 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en.h         |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |   8 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    |  72 +++++++++++++++++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c    |  48 ++++++++++---------------
 drivers/net/ethernet/mellanox/mlx5/core/main.c       |  25 ++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/port.c       |  10 +++---
 drivers/net/ethernet/mellanox/mlx5/core/vport.c      |  40 +++++++++++++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h          |   4 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c  |  50 +++++++++-----------------
 drivers/net/macsec.c                                 |  65 ++++++++++++++++++++++------------
 drivers/scsi/cxgbi/libcxgbi.c                        |   1 +
 include/linux/mlx5/driver.h                          |   7 ++--
 include/linux/mlx5/port.h                            |   6 ++--
 include/linux/mlx5/vport.h                           |   2 ++
 include/net/switchdev.h                              |   4 +++
 include/uapi/linux/if_macsec.h                       |   4 +--
 kernel/bpf/verifier.c                                |   1 -
 net/bridge/br_mdb.c                                  | 124 +++++++++++++++++++++++++++++++++++++++++-----------------------
 net/bridge/br_multicast.c                            |   8 +++--
 net/bridge/br_private.h                              |   4 +--
 net/ipv4/fib_frontend.c                              |   6 +++-
 net/ipv6/addrconf.c                                  |  48 ++++++++-----------------
 net/switchdev/switchdev.c                            |   6 ++++
 27 files changed, 351 insertions(+), 218 deletions(-)
