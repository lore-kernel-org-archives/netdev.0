From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next V2 1/1] {net, IB}/mlx5: Reorganize driver file layout
Date: Thu, 12 Jan 2017 21:29:34 +0200
Message-ID: <20170112192934.25662-2-saeedm@mellanox.com>
References: <20170112192934.25662-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170112192934.25662-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

This patch organizes mlx5 driver file layout to better reflect mlx5
modularity and allow future separation between EN, IB and shared code
parts.

The new structure:
 * drivers/net/ethernet/mellanox/mlx5/*       - core HW/PCI driver logic
 * drivers/net/ethernet/mellanox/mlx5/en/*    - ethernet
 * drivers/net/ethernet/mellanox/mlx5/fs/*    - flow steering
 * drivers/net/ethernet/mellanox/mlx5/sriov/* - SR-IOV and E-Switch
 * drivers/net/ethernet/mellanox/mlx5/lib/*   - common mlx5 commands and API library

In future submissions, we will shrink the "lib" directory to the code
related to both subsystems only, while IB part will be moved to
drivers/infiniband/hw/mlx5, and EN will be moved to "en" directory.
Such separation will make this library (shared) code to be lean and minimal,
and help avoid future conflicts between IB and net submissions.

The proposed structure allows us to remove include/linux/mlx5,
which belongs solely to Mellanox's devices and don't need to
be exposed in common linux include directory.

The following change goes together with update of MAINTAINERS file to
more granular maintainership roles:
 * drivers/net/ethernet/mellanox/mlx5/*       - Saeed, Matan and Leon
 * drivers/net/ethernet/mellanox/mlx5/en/*    - Saeed
 * drivers/net/ethernet/mellanox/mlx5/fs/*    - Saeed, Matan and Leon
 * drivers/net/ethernet/mellanox/mlx5/sriov/* - Saeed
 * drivers/net/ethernet/mellanox/mlx5/lib/*   - Saeed, Matan and Leon
 * include/uapi/rdma/mlx5-abi.h               - Matan and Leon

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 MAINTAINERS                                         | 11 ++++++-----
 drivers/infiniband/hw/mlx5/Makefile                 |  1 +
 drivers/infiniband/hw/mlx5/ib_virt.c                |  2 +-
 drivers/infiniband/hw/mlx5/mad.c                    |  4 ++--
 drivers/infiniband/hw/mlx5/main.c                   |  6 +++---
 drivers/infiniband/hw/mlx5/mlx5_ib.h                | 10 +++++-----
 drivers/infiniband/hw/mlx5/srq.c                    |  4 ++--
 drivers/net/ethernet/mellanox/Kconfig               |  2 +-
 drivers/net/ethernet/mellanox/Makefile              |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => }/Kconfig   |  0
 drivers/net/ethernet/mellanox/mlx5/Makefile         | 21 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/{core => }/cmd.c |  5 ++---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile    | 13 -------------
 .../net/ethernet/mellanox/mlx5/{core => }/debugfs.c |  8 ++++----
 drivers/net/ethernet/mellanox/mlx5/{core => }/dev.c |  4 ++--
 .../mellanox/mlx5/{core/en_arfs.c => en/arfs.c}     |  4 ++--
 .../mellanox/mlx5/{core/en_clock.c => en/clock.c}   |  2 +-
 .../mellanox/mlx5/{core/en_common.c => en/common.c} |  2 +-
 .../mellanox/mlx5/{core/en_dcbnl.c => en/dcbnl.c}   |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => en}/en.h    | 18 +++++++++---------
 .../mlx5/{core/en_ethtool.c => en/ethtool.c}        |  2 +-
 .../mellanox/mlx5/{core/en_fs.c => en/fs.c}         |  4 ++--
 .../mlx5/{core/en_fs_ethtool.c => en/fs_ethtool.c}  |  4 ++--
 .../mellanox/mlx5/{core/en_main.c => en/main.c}     | 10 +++++-----
 .../mellanox/mlx5/{core/en_rep.c => en/rep.c}       |  8 ++++----
 .../mellanox/mlx5/{core/en_rx.c => en/rx.c}         |  6 +++---
 .../mellanox/mlx5/{core/en_rx_am.c => en/rx_am.c}   |  2 +-
 .../mlx5/{core/en_selftest.c => en/selftest.c}      |  2 +-
 .../mellanox/mlx5/{core/en_stats.h => en/stats.h}   |  0
 .../mellanox/mlx5/{core/en_tc.c => en/tc.c}         | 12 ++++++------
 .../mellanox/mlx5/{core/en_tc.h => en/tc.h}         |  0
 .../mellanox/mlx5/{core/en_tx.c => en/tx.c}         |  2 +-
 .../mellanox/mlx5/{core/en_txrx.c => en/txrx.c}     |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => en}/vxlan.c |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => en}/vxlan.h |  4 ++--
 .../net/ethernet/mellanox/mlx5/{core => en}/wq.c    |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => en}/wq.h    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/{core => }/eq.c  |  8 ++++----
 .../mellanox/mlx5/{core/fs_cmd.c => fs/cmd.c}       | 15 +++++++--------
 .../mellanox/mlx5/{core/fs_cmd.h => fs/cmd.h}       |  0
 .../mellanox/mlx5/{core/fs_core.c => fs/core.c}     |  9 ++++-----
 .../mellanox/mlx5/{core/fs_core.h => fs/core.h}     |  2 +-
 .../mlx5/{core/fs_counters.c => fs/counters.c}      | 10 +++++-----
 .../net/ethernet/mellanox/mlx5/{core => }/health.c  |  6 +++---
 drivers/net/ethernet/mellanox/mlx5/{core => }/lag.c |  6 +++---
 .../ethernet/mellanox/mlx5/{core => lib}/alloc.c    |  5 ++---
 .../net/ethernet/mellanox/mlx5/lib}/cmd.h           |  0
 .../net/ethernet/mellanox/mlx5/{core => lib}/cq.c   |  8 ++++----
 .../net/ethernet/mellanox/mlx5/lib}/cq.h            |  2 +-
 .../net/ethernet/mellanox/mlx5/lib}/device.h        |  2 +-
 .../net/ethernet/mellanox/mlx5/lib}/doorbell.h      |  0
 .../net/ethernet/mellanox/mlx5/lib}/driver.h        |  6 +++---
 .../net/ethernet/mellanox/mlx5/lib}/fs.h            |  4 ++--
 .../net/ethernet/mellanox/mlx5/{core => lib}/fw.c   |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/mad.c  |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/mcg.c  |  6 +++---
 .../net/ethernet/mellanox/mlx5/lib}/mlx5_ifc.h      |  0
 .../net/ethernet/mellanox/mlx5/{core => lib}/mr.c   |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/pd.c   |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/port.c |  8 ++++----
 .../net/ethernet/mellanox/mlx5/lib}/port.h          |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => lib}/qp.c   | 11 +++++------
 .../net/ethernet/mellanox/mlx5/lib}/qp.h            |  4 ++--
 .../net/ethernet/mellanox/mlx5/{core => lib}/rl.c   |  6 +++---
 .../net/ethernet/mellanox/mlx5/{core => lib}/srq.c  | 10 +++++-----
 .../net/ethernet/mellanox/mlx5/lib}/srq.h           |  2 +-
 .../ethernet/mellanox/mlx5/{core => lib}/transobj.c |  6 +++---
 .../net/ethernet/mellanox/mlx5/lib}/transobj.h      |  2 +-
 .../net/ethernet/mellanox/mlx5/{core => lib}/uar.c  |  6 +++---
 .../ethernet/mellanox/mlx5/{core => lib}/vport.c    |  6 +++---
 .../net/ethernet/mellanox/mlx5/lib}/vport.h         |  4 ++--
 .../net/ethernet/mellanox/mlx5/{core => }/main.c    | 16 ++++++++--------
 .../mellanox/mlx5/{core/mlx5_core.h => mlx5.h}      |  0
 .../ethernet/mellanox/mlx5/{core => }/pagealloc.c   |  6 +++---
 .../mellanox/mlx5/{core => sriov}/eswitch.c         | 12 ++++++------
 .../mellanox/mlx5/{core => sriov}/eswitch.h         |  2 +-
 .../mlx5/{core => sriov}/eswitch_offloads.c         | 12 ++++++------
 .../ethernet/mellanox/mlx5/{core => sriov}/sriov.c  |  6 +++---
 78 files changed, 216 insertions(+), 211 deletions(-)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/Kconfig (100%)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/Makefile
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/cmd.c (99%)
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/Makefile
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/debugfs.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/dev.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_arfs.c => en/arfs.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_clock.c => en/clock.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_common.c => en/common.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_dcbnl.c => en/dcbnl.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/en.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_ethtool.c => en/ethtool.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_fs.c => en/fs.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_fs_ethtool.c => en/fs_ethtool.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_main.c => en/main.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_rep.c => en/rep.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_rx.c => en/rx.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_rx_am.c => en/rx_am.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_selftest.c => en/selftest.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_stats.h => en/stats.h} (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_tc.c => en/tc.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_tc.h => en/tc.h} (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_tx.c => en/tx.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/en_txrx.c => en/txrx.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/vxlan.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/vxlan.h (97%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/wq.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => en}/wq.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/eq.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_cmd.c => fs/cmd.c} (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_cmd.h => fs/cmd.h} (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_core.c => fs/core.c} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_core.h => fs/core.h} (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/fs_counters.c => fs/counters.c} (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/health.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/lag.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/alloc.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/cmd.h (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/cq.c (98%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/cq.h (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/device.h (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/doorbell.h (100%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/driver.h (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/fs.h (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/fw.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/mad.c (96%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/mcg.c (96%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/mlx5_ifc.h (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/mr.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/pd.c (96%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/port.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/port.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/qp.c (98%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/qp.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/rl.c (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/srq.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/srq.h (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/transobj.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/transobj.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/uar.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => lib}/vport.c (99%)
 rename {include/linux/mlx5 => drivers/net/ethernet/mellanox/mlx5/lib}/vport.h (98%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/main.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core/mlx5_core.h => mlx5.h} (100%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => }/pagealloc.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => sriov}/eswitch.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => sriov}/eswitch.h (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => sriov}/eswitch_offloads.c (99%)
 rename drivers/net/ethernet/mellanox/mlx5/{core => sriov}/sriov.c (98%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 11904a95672a..5c1f390e3046 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8045,7 +8045,8 @@ L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 S:	Supported
 W:	http://www.mellanox.com
 Q:	http://patchwork.ozlabs.org/project/netdev/list/
-F:	drivers/net/ethernet/mellanox/mlx5/core/en_*
+F:	drivers/net/ethernet/mellanox/mlx5/en/
+F:	drivers/net/ethernet/mellanox/mlx5/sriov/
 
 MELLANOX ETHERNET SWITCH DRIVERS
 M:	Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
@@ -8256,9 +8257,9 @@ L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://www.mellanox.com
 Q:	http://patchwork.ozlabs.org/project/netdev/list/
 S:	Supported
-F:	drivers/net/ethernet/mellanox/mlx5/core/
-F:	include/linux/mlx5/
-F:	include/uapi/rdma/mlx5-abi.h
+F:	drivers/net/ethernet/mellanox/mlx5/*
+F:	drivers/net/ethernet/mellanox/mlx5/lib/
+F:	drivers/net/ethernet/mellanox/mlx5/fs/
 
 MELLANOX MLX5 IB driver
 M:	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
@@ -8268,7 +8269,7 @@ W:	http://www.mellanox.com
 Q:	http://patchwork.kernel.org/project/linux-rdma/list/
 S:	Supported
 F:	drivers/infiniband/hw/mlx5/
-F:	include/linux/mlx5/
+F:	include/uapi/rdma/mlx5-abi.h
 
 MELEXIS MLX90614 DRIVER
 M:	Crt Mori <cmo-fc6wVz46lShBDgjK7y7TUQ@public.gmane.org>
diff --git a/drivers/infiniband/hw/mlx5/Makefile b/drivers/infiniband/hw/mlx5/Makefile
index 7493a83acd28..6d8e7e0b0d4a 100644
--- a/drivers/infiniband/hw/mlx5/Makefile
+++ b/drivers/infiniband/hw/mlx5/Makefile
@@ -1,3 +1,4 @@
+ccflags-y := -I$(srctree)/drivers/net/ethernet/mellanox/mlx5/
 obj-$(CONFIG_MLX5_INFINIBAND)	+= mlx5_ib.o
 
 mlx5_ib-y :=	main.o cq.o doorbell.o qp.o mem.o srq.o mr.o ah.o mad.o gsi.o ib_virt.o
diff --git a/drivers/infiniband/hw/mlx5/ib_virt.c b/drivers/infiniband/hw/mlx5/ib_virt.c
index c1b9de800fe5..c1a749bddc88 100644
--- a/drivers/infiniband/hw/mlx5/ib_virt.c
+++ b/drivers/infiniband/hw/mlx5/ib_virt.c
@@ -31,7 +31,7 @@
  */
 
 #include <linux/module.h>
-#include <linux/mlx5/vport.h>
+#include "lib/vport.h"
 #include "mlx5_ib.h"
 
 static inline u32 mlx_to_net_policy(enum port_state_policy mlx_policy)
diff --git a/drivers/infiniband/hw/mlx5/mad.c b/drivers/infiniband/hw/mlx5/mad.c
index 39e58489dcc2..72b081a44c97 100644
--- a/drivers/infiniband/hw/mlx5/mad.c
+++ b/drivers/infiniband/hw/mlx5/mad.c
@@ -30,8 +30,8 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx5/cmd.h>
-#include <linux/mlx5/vport.h>
+#include "lib/cmd.h"
+#include "lib/vport.h"
 #include <rdma/ib_mad.h>
 #include <rdma/ib_smi.h>
 #include <rdma/ib_pma.h>
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index a191b9327b0c..086746262a2c 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -45,14 +45,14 @@
 #include <rdma/ib_user_verbs.h>
 #include <rdma/ib_addr.h>
 #include <rdma/ib_cache.h>
-#include <linux/mlx5/port.h>
-#include <linux/mlx5/vport.h>
+#include "lib/port.h"
+#include "lib/vport.h"
 #include <linux/list.h>
 #include <rdma/ib_smi.h>
 #include <rdma/ib_umem.h>
 #include <linux/in.h>
 #include <linux/etherdevice.h>
-#include <linux/mlx5/fs.h>
+#include "lib/fs.h"
 #include "mlx5_ib.h"
 
 #define DRIVER_NAME "mlx5_ib"
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index e1a4b93dce6b..fe5c8dabab81 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -37,12 +37,12 @@
 #include <linux/sched.h>
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_smi.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cq.h>
-#include <linux/mlx5/qp.h>
-#include <linux/mlx5/srq.h>
+#include "lib/driver.h"
+#include "lib/cq.h"
+#include "lib/qp.h"
+#include "lib/srq.h"
 #include <linux/types.h>
-#include <linux/mlx5/transobj.h>
+#include "lib/transobj.h"
 #include <rdma/ib_user_verbs.h>
 #include <rdma/mlx5-abi.h>
 
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 6f4397ee1ed6..949b8d80d28b 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -31,8 +31,8 @@
  */
 
 #include <linux/module.h>
-#include <linux/mlx5/qp.h>
-#include <linux/mlx5/srq.h>
+#include "lib/qp.h"
+#include "lib/srq.h"
 #include <linux/slab.h>
 #include <rdma/ib_umem.h>
 #include <rdma/ib_user_verbs.h>
diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index d54701047401..214b3787f419 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -17,7 +17,7 @@ config NET_VENDOR_MELLANOX
 if NET_VENDOR_MELLANOX
 
 source "drivers/net/ethernet/mellanox/mlx4/Kconfig"
-source "drivers/net/ethernet/mellanox/mlx5/core/Kconfig"
+source "drivers/net/ethernet/mellanox/mlx5/Kconfig"
 source "drivers/net/ethernet/mellanox/mlxsw/Kconfig"
 
 endif # NET_VENDOR_MELLANOX
diff --git a/drivers/net/ethernet/mellanox/Makefile b/drivers/net/ethernet/mellanox/Makefile
index 2e2a5ec509ac..a65d5929f19d 100644
--- a/drivers/net/ethernet/mellanox/Makefile
+++ b/drivers/net/ethernet/mellanox/Makefile
@@ -3,5 +3,5 @@
 #
 
 obj-$(CONFIG_MLX4_CORE) += mlx4/
-obj-$(CONFIG_MLX5_CORE) += mlx5/core/
+obj-$(CONFIG_MLX5_CORE) += mlx5/
 obj-$(CONFIG_MLXSW_CORE) += mlxsw/
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/Kconfig
similarity index 100%
rename from drivers/net/ethernet/mellanox/mlx5/core/Kconfig
rename to drivers/net/ethernet/mellanox/mlx5/Kconfig
diff --git a/drivers/net/ethernet/mellanox/mlx5/Makefile b/drivers/net/ethernet/mellanox/mlx5/Makefile
new file mode 100644
index 000000000000..9634f090d810
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/Makefile
@@ -0,0 +1,21 @@
+subdir-ccflags-y := -I$(srctree)/drivers/net/ethernet/mellanox/mlx5/
+obj-$(CONFIG_MLX5_CORE)		+= mlx5_core.o
+
+mlx5_core-y := main.o pagealloc.o health.o \
+	       cmd.o debugfs.o eq.o lag.o dev.o
+
+mlx5_core-y += lib/fw.o lib/uar.o lib/mcg.o lib/cq.o \
+	       lib/srq.o lib/alloc.o lib/qp.o lib/port.o lib/mr.o \
+	       lib/pd.o lib/mad.o lib/transobj.o lib/vport.o lib/rl.o
+
+mlx5_core-y += sriov/sriov.o
+mlx5_core-y += fs/cmd.o fs/core.o fs/counters.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN) += en/wq.o en/main.o en/common.o \
+		en/fs.o en/ethtool.o en/tx.o en/rx.o en/rx_am.o \
+		en/txrx.o en/clock.o en/vxlan.o en/tc.o en/arfs.o \
+		en/rep.o en/fs_ethtool.o en/selftest.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN) += sriov/eswitch.o sriov/eswitch_offloads.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) += en/dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/cmd.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/cmd.c
rename to drivers/net/ethernet/mellanox/mlx5/cmd.c
index 3797cc7c1288..1922e98dc10d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/cmd.c
@@ -39,10 +39,9 @@
 #include <linux/delay.h>
 #include <linux/random.h>
 #include <linux/io-mapping.h>
-#include <linux/mlx5/driver.h>
+#include "lib/driver.h"
 #include <linux/debugfs.h>
-
-#include "mlx5_core.h"
+#include "mlx5.h"
 
 enum {
 	CMD_IF_REV = 5,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
deleted file mode 100644
index 9f43beb86250..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ /dev/null
@@ -1,13 +0,0 @@
-obj-$(CONFIG_MLX5_CORE)		+= mlx5_core.o
-
-mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
-		health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o \
-		mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o \
-		fs_counters.o rl.o lag.o dev.o
-
-mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
-		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
-		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
-		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
-
-mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/net/ethernet/mellanox/mlx5/debugfs.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
rename to drivers/net/ethernet/mellanox/mlx5/debugfs.c
index e94a9532e218..0dfa686c1da0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/debugfs.c
@@ -32,10 +32,10 @@
 
 #include <linux/module.h>
 #include <linux/debugfs.h>
-#include <linux/mlx5/qp.h>
-#include <linux/mlx5/cq.h>
-#include <linux/mlx5/driver.h>
-#include "mlx5_core.h"
+#include "lib/qp.h"
+#include "lib/cq.h"
+#include "lib/driver.h"
+#include "mlx5.h"
 
 enum {
 	QP_PID,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/dev.c b/drivers/net/ethernet/mellanox/mlx5/dev.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/dev.c
rename to drivers/net/ethernet/mellanox/mlx5/dev.c
index a62f4b6a21a5..3d43b1eb8cdf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/dev.c
+++ b/drivers/net/ethernet/mellanox/mlx5/dev.c
@@ -30,8 +30,8 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx5/driver.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "mlx5.h"
 
 static LIST_HEAD(intf_list);
 static LIST_HEAD(mlx5_dev_list);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/en/arfs.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
rename to drivers/net/ethernet/mellanox/mlx5/en/arfs.c
index 68419a01db36..6d3bcb863c9c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/arfs.c
@@ -33,10 +33,10 @@
 #ifdef CONFIG_RFS_ACCEL
 
 #include <linux/hash.h>
-#include <linux/mlx5/fs.h>
+#include "lib/fs.h"
 #include <linux/ip.h>
 #include <linux/ipv6.h>
-#include "en.h"
+#include "en/en.h"
 
 struct arfs_tuple {
 	__be16 etype;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/en/clock.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
rename to drivers/net/ethernet/mellanox/mlx5/en/clock.c
index 746a92c13644..a72faff5b1d1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/clock.c
@@ -31,7 +31,7 @@
  */
 
 #include <linux/clocksource.h>
-#include "en.h"
+#include "en/en.h"
 
 enum {
 	MLX5E_CYCLES_SHIFT	= 23
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/en/common.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_common.c
rename to drivers/net/ethernet/mellanox/mlx5/en/common.c
index bd898d8deda0..bf4f824d66dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/common.c
@@ -30,7 +30,7 @@
  * SOFTWARE.
  */
 
-#include "en.h"
+#include "en/en.h"
 
 /* mlx5e global resources should be placed in this file.
  * Global resources are common to all the netdevices crated on the same nic.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/en/dcbnl.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
rename to drivers/net/ethernet/mellanox/mlx5/en/dcbnl.c
index 7f6c225666c1..4a5a89e45962 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/dcbnl.c
@@ -31,7 +31,7 @@
  */
 #include <linux/device.h>
 #include <linux/netdevice.h>
-#include "en.h"
+#include "en/en.h"
 
 #define MLX5E_MAX_PRIORITY 8
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/en/en.h
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en.h
rename to drivers/net/ethernet/mellanox/mlx5/en/en.h
index a473cea10c16..5f5f209801a8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/en/en.h
@@ -37,17 +37,17 @@
 #include <linux/timecounter.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/qp.h>
-#include <linux/mlx5/cq.h>
-#include <linux/mlx5/port.h>
-#include <linux/mlx5/vport.h>
-#include <linux/mlx5/transobj.h>
+#include "lib/driver.h"
+#include "lib/qp.h"
+#include "lib/cq.h"
+#include "lib/port.h"
+#include "lib/vport.h"
+#include "lib/transobj.h"
 #include <linux/rhashtable.h>
 #include <net/switchdev.h>
-#include "wq.h"
-#include "mlx5_core.h"
-#include "en_stats.h"
+#include "en/wq.h"
+#include "mlx5.h"
+#include "en/stats.h"
 
 #define MLX5_SET_CFG(p, f, v) MLX5_SET(create_flow_group_in, p, f, v)
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/en/ethtool.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
rename to drivers/net/ethernet/mellanox/mlx5/en/ethtool.c
index 352462af8d51..0cae50d7c774 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/ethtool.c
@@ -30,7 +30,7 @@
  * SOFTWARE.
  */
 
-#include "en.h"
+#include "en/en.h"
 
 static void mlx5e_get_drvinfo(struct net_device *dev,
 			      struct ethtool_drvinfo *drvinfo)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/en/fs.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
rename to drivers/net/ethernet/mellanox/mlx5/en/fs.c
index 1fe80de5d68f..cd7499c8e717 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/fs.c
@@ -34,8 +34,8 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
-#include <linux/mlx5/fs.h>
-#include "en.h"
+#include "lib/fs.h"
+#include "en/en.h"
 
 static int mlx5e_add_l2_flow_rule(struct mlx5e_priv *priv,
 				  struct mlx5e_l2_rule *ai, int type);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/en/fs_ethtool.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
rename to drivers/net/ethernet/mellanox/mlx5/en/fs_ethtool.c
index 3691451c728c..4459f1c04013 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/fs_ethtool.c
@@ -30,8 +30,8 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx5/fs.h>
-#include "en.h"
+#include "lib/fs.h"
+#include "en/en.h"
 
 struct mlx5e_ethtool_rule {
 	struct list_head             list;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/en/main.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_main.c
rename to drivers/net/ethernet/mellanox/mlx5/en/main.c
index c32754b1598e..b537df74a01c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/main.c
@@ -32,13 +32,13 @@
 
 #include <net/tc_act/tc_gact.h>
 #include <net/pkt_cls.h>
-#include <linux/mlx5/fs.h>
+#include "lib/fs.h"
 #include <net/vxlan.h>
 #include <linux/bpf.h>
-#include "en.h"
-#include "en_tc.h"
-#include "eswitch.h"
-#include "vxlan.h"
+#include "en/en.h"
+#include "en/tc.h"
+#include "sriov/eswitch.h"
+#include "en/vxlan.h"
 
 struct mlx5e_rq_param {
 	u32			rqc[MLX5_ST_SZ_DW(rqc)];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/en/rep.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
rename to drivers/net/ethernet/mellanox/mlx5/en/rep.c
index 850378893b25..72926bd37e1a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/rep.c
@@ -31,13 +31,13 @@
  */
 
 #include <generated/utsrelease.h>
-#include <linux/mlx5/fs.h>
+#include "lib/fs.h"
 #include <net/switchdev.h>
 #include <net/pkt_cls.h>
 
-#include "eswitch.h"
-#include "en.h"
-#include "en_tc.h"
+#include "sriov/eswitch.h"
+#include "en/en.h"
+#include "en/tc.h"
 
 static const char mlx5e_rep_driver_name[] = "mlx5e_rep";
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/en/rx.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
rename to drivers/net/ethernet/mellanox/mlx5/en/rx.c
index 0e2fb3ed1790..edfbdb91bab8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/rx.c
@@ -34,9 +34,9 @@
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
 #include <net/busy_poll.h>
-#include "en.h"
-#include "en_tc.h"
-#include "eswitch.h"
+#include "en/en.h"
+#include "en/tc.h"
+#include "sriov/eswitch.h"
 
 static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c b/drivers/net/ethernet/mellanox/mlx5/en/rx_am.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
rename to drivers/net/ethernet/mellanox/mlx5/en/rx_am.c
index 1fffe48a93cc..caaf7b2da363 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/rx_am.c
@@ -30,7 +30,7 @@
  * SOFTWARE.
  */
 
-#include "en.h"
+#include "en/en.h"
 
 /* Adaptive moderation profiles */
 #define MLX5E_AM_DEFAULT_RX_CQ_MODERATION_PKTS_FROM_EQE 256
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/en/selftest.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
rename to drivers/net/ethernet/mellanox/mlx5/en/selftest.c
index 65442c36a6e1..b37568290aeb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/selftest.c
@@ -33,7 +33,7 @@
 #include <linux/ip.h>
 #include <linux/udp.h>
 #include <net/udp.h>
-#include "en.h"
+#include "en/en.h"
 
 enum {
 	MLX5E_ST_LINK_STATE,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/en/stats.h
similarity index 100%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
rename to drivers/net/ethernet/mellanox/mlx5/en/stats.h
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/en/tc.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
rename to drivers/net/ethernet/mellanox/mlx5/en/tc.c
index f8829b517156..2506736c941d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/tc.c
@@ -35,18 +35,18 @@
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_skbedit.h>
-#include <linux/mlx5/fs.h>
-#include <linux/mlx5/device.h>
+#include "lib/fs.h"
+#include "lib/device.h"
 #include <linux/rhashtable.h>
 #include <net/switchdev.h>
 #include <net/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_vlan.h>
 #include <net/tc_act/tc_tunnel_key.h>
 #include <net/vxlan.h>
-#include "en.h"
-#include "en_tc.h"
-#include "eswitch.h"
-#include "vxlan.h"
+#include "en/en.h"
+#include "en/tc.h"
+#include "sriov/eswitch.h"
+#include "en/vxlan.h"
 
 struct mlx5e_tc_flow {
 	struct rhash_head	node;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/en/tc.h
similarity index 100%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
rename to drivers/net/ethernet/mellanox/mlx5/en/tc.h
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/en/tx.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
rename to drivers/net/ethernet/mellanox/mlx5/en/tx.c
index cfb68371c397..1aa99cde89e9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/tx.c
@@ -32,7 +32,7 @@
 
 #include <linux/tcp.h>
 #include <linux/if_vlan.h>
-#include "en.h"
+#include "en/en.h"
 
 #define MLX5E_SQ_NOPS_ROOM  MLX5_SEND_WQE_MAX_WQEBBS
 #define MLX5E_SQ_STOP_ROOM (MLX5_SEND_WQE_MAX_WQEBBS +\
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/en/txrx.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
rename to drivers/net/ethernet/mellanox/mlx5/en/txrx.c
index e5c12a732aa1..8bd46494663f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/txrx.c
@@ -30,7 +30,7 @@
  * SOFTWARE.
  */
 
-#include "en.h"
+#include "en/en.h"
 
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c b/drivers/net/ethernet/mellanox/mlx5/en/vxlan.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
rename to drivers/net/ethernet/mellanox/mlx5/en/vxlan.c
index 07a9ba6cfc70..575105a7d76a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/vxlan.c
@@ -32,9 +32,9 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include "mlx5_core.h"
-#include "vxlan.h"
+#include "lib/driver.h"
+#include "mlx5.h"
+#include "en/vxlan.h"
 
 void mlx5e_vxlan_init(struct mlx5e_priv *priv)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h b/drivers/net/ethernet/mellanox/mlx5/en/vxlan.h
similarity index 97%
rename from drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
rename to drivers/net/ethernet/mellanox/mlx5/en/vxlan.h
index 5def12c048e3..579827fba0f4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
+++ b/drivers/net/ethernet/mellanox/mlx5/en/vxlan.h
@@ -32,8 +32,8 @@
 #ifndef __MLX5_VXLAN_H__
 #define __MLX5_VXLAN_H__
 
-#include <linux/mlx5/driver.h>
-#include "en.h"
+#include "lib/driver.h"
+#include "en/en.h"
 
 struct mlx5e_vxlan {
 	u16 udp_port;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.c b/drivers/net/ethernet/mellanox/mlx5/en/wq.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/wq.c
rename to drivers/net/ethernet/mellanox/mlx5/en/wq.c
index 921673c42bc9..4efc67b118da 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/wq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/en/wq.c
@@ -30,9 +30,9 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx5/driver.h>
-#include "wq.h"
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "en/wq.h"
+#include "mlx5.h"
 
 u32 mlx5_wq_cyc_get_size(struct mlx5_wq_cyc *wq)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.h b/drivers/net/ethernet/mellanox/mlx5/en/wq.h
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/wq.h
rename to drivers/net/ethernet/mellanox/mlx5/en/wq.h
index d8afed898c31..7e0e468b0c8f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/wq.h
+++ b/drivers/net/ethernet/mellanox/mlx5/en/wq.h
@@ -33,7 +33,7 @@
 #ifndef __MLX5_WQ_H__
 #define __MLX5_WQ_H__
 
-#include <linux/mlx5/mlx5_ifc.h>
+#include "lib/mlx5_ifc.h"
 
 struct mlx5_wq_param {
 	int		linear;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/eq.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/eq.c
rename to drivers/net/ethernet/mellanox/mlx5/eq.c
index 5130d65dd41a..2b5cf44d0f4c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/eq.c
@@ -32,11 +32,11 @@
 
 #include <linux/interrupt.h>
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 #ifdef CONFIG_MLX5_CORE_EN
-#include "eswitch.h"
+#include <sriov/eswitch.h>
 #endif
 
 enum {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/fs/cmd.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
rename to drivers/net/ethernet/mellanox/mlx5/fs/cmd.c
index c4478ecd8056..ce1ff6f0c524 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/fs/cmd.c
@@ -30,14 +30,13 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/device.h>
-#include <linux/mlx5/mlx5_ifc.h>
-
-#include "fs_core.h"
-#include "fs_cmd.h"
-#include "mlx5_core.h"
-#include "eswitch.h"
+#include "lib/driver.h"
+#include "lib/device.h"
+#include "lib/mlx5_ifc.h"
+#include "fs/core.h"
+#include "fs/cmd.h"
+#include "mlx5.h"
+#include "sriov/eswitch.h"
 
 int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 			    struct mlx5_flow_table *ft)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/fs/cmd.h
similarity index 100%
rename from drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
rename to drivers/net/ethernet/mellanox/mlx5/fs/cmd.h
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/fs/core.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
rename to drivers/net/ethernet/mellanox/mlx5/fs/core.c
index a263d8904a4c..6a8283f4123b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/fs/core.c
@@ -31,11 +31,10 @@
  */
 
 #include <linux/mutex.h>
-#include <linux/mlx5/driver.h>
-
-#include "mlx5_core.h"
-#include "fs_core.h"
-#include "fs_cmd.h"
+#include "lib/driver.h"
+#include "mlx5.h"
+#include "fs/core.h"
+#include "fs/cmd.h"
 
 #define INIT_TREE_NODE_ARRAY_SIZE(...)	(sizeof((struct init_tree_node[]){__VA_ARGS__}) /\
 					 sizeof(struct init_tree_node))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/fs/core.h
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
rename to drivers/net/ethernet/mellanox/mlx5/fs/core.h
index 8e668c63f69e..3c605bd992e6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/fs/core.h
@@ -33,7 +33,7 @@
 #ifndef _MLX5_FS_CORE_
 #define _MLX5_FS_CORE_
 
-#include <linux/mlx5/fs.h>
+#include "lib/fs.h"
 
 enum fs_node_type {
 	FS_TYPE_NAMESPACE,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/fs/counters.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
rename to drivers/net/ethernet/mellanox/mlx5/fs/counters.c
index 7431f633de31..19f4c97715b1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/fs/counters.c
@@ -30,12 +30,12 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/fs.h>
+#include "lib/driver.h"
+#include "lib/fs.h"
 #include <linux/rbtree.h>
-#include "mlx5_core.h"
-#include "fs_core.h"
-#include "fs_cmd.h"
+#include "mlx5.h"
+#include "fs/core.h"
+#include "fs/cmd.h"
 
 #define MLX5_FC_STATS_PERIOD msecs_to_jiffies(1000)
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/health.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/health.c
rename to drivers/net/ethernet/mellanox/mlx5/health.c
index 5bcf93422ee0..7af5593a6201 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/health.c
@@ -35,9 +35,9 @@
 #include <linux/random.h>
 #include <linux/vmalloc.h>
 #include <linux/hardirq.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 
 enum {
 	MLX5_HEALTH_POLL_INTERVAL	= 2 * HZ,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/lag.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/lag.c
rename to drivers/net/ethernet/mellanox/mlx5/lag.c
index 55957246c0e8..c0338a528c4a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lag.c
@@ -31,9 +31,9 @@
  */
 
 #include <linux/netdevice.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/vport.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/vport.h"
+#include "mlx5.h"
 
 enum {
 	MLX5_LAG_FLAG_BONDED = 1 << 0,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/lib/alloc.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/alloc.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/alloc.c
index 66bd213f35ce..2f3bbff03c59 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/alloc.c
@@ -37,9 +37,8 @@
 #include <linux/bitmap.h>
 #include <linux/dma-mapping.h>
 #include <linux/vmalloc.h>
-#include <linux/mlx5/driver.h>
-
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "mlx5.h"
 
 struct mlx5_db_pgdir {
 	struct list_head	list;
diff --git a/include/linux/mlx5/cmd.h b/drivers/net/ethernet/mellanox/mlx5/lib/cmd.h
similarity index 100%
rename from include/linux/mlx5/cmd.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/cmd.h
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cq.c b/drivers/net/ethernet/mellanox/mlx5/lib/cq.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/cq.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/cq.c
index 336d4738b807..1c2e8124073f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/cq.c
@@ -33,11 +33,11 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/hardirq.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
+#include "lib/driver.h"
+#include "lib/cmd.h"
 #include <rdma/ib_verbs.h>
-#include <linux/mlx5/cq.h>
-#include "mlx5_core.h"
+#include "lib/cq.h"
+#include "mlx5.h"
 
 #define TASKLET_MAX_TIME 2
 #define TASKLET_MAX_TIME_JIFFIES msecs_to_jiffies(TASKLET_MAX_TIME)
diff --git a/include/linux/mlx5/cq.h b/drivers/net/ethernet/mellanox/mlx5/lib/cq.h
similarity index 99%
rename from include/linux/mlx5/cq.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/cq.h
index 95898847c7d4..380875ac6753 100644
--- a/include/linux/mlx5/cq.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/cq.h
@@ -34,7 +34,7 @@
 #define MLX5_CORE_CQ_H
 
 #include <rdma/ib_verbs.h>
-#include <linux/mlx5/driver.h>
+#include "driver.h"
 
 
 struct mlx5_core_cq {
diff --git a/include/linux/mlx5/device.h b/drivers/net/ethernet/mellanox/mlx5/lib/device.h
similarity index 99%
rename from include/linux/mlx5/device.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/device.h
index dd345e8cf6f0..dcbc05483838 100644
--- a/include/linux/mlx5/device.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/device.h
@@ -35,7 +35,7 @@
 
 #include <linux/types.h>
 #include <rdma/ib_verbs.h>
-#include <linux/mlx5/mlx5_ifc.h>
+#include "mlx5_ifc.h"
 
 #if defined(__LITTLE_ENDIAN)
 #define MLX5_SET_HOST_ENDIANNESS	0
diff --git a/include/linux/mlx5/doorbell.h b/drivers/net/ethernet/mellanox/mlx5/lib/doorbell.h
similarity index 100%
rename from include/linux/mlx5/doorbell.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/doorbell.h
diff --git a/include/linux/mlx5/driver.h b/drivers/net/ethernet/mellanox/mlx5/lib/driver.h
similarity index 99%
rename from include/linux/mlx5/driver.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/driver.h
index 10e632588cd5..632bd3e720a9 100644
--- a/include/linux/mlx5/driver.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/driver.h
@@ -45,9 +45,9 @@
 #include <linux/mempool.h>
 #include <linux/interrupt.h>
 
-#include <linux/mlx5/device.h>
-#include <linux/mlx5/doorbell.h>
-#include <linux/mlx5/srq.h>
+#include "lib/device.h"
+#include "lib/doorbell.h"
+#include "lib/srq.h"
 
 enum {
 	MLX5_BOARD_ID_LEN = 64,
diff --git a/include/linux/mlx5/fs.h b/drivers/net/ethernet/mellanox/mlx5/lib/fs.h
similarity index 98%
rename from include/linux/mlx5/fs.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/fs.h
index 949b24b6c479..df43b1455961 100644
--- a/include/linux/mlx5/fs.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/fs.h
@@ -33,8 +33,8 @@
 #ifndef _MLX5_FS_
 #define _MLX5_FS_
 
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/mlx5_ifc.h>
+#include "lib/driver.h"
+#include "lib/mlx5_ifc.h"
 
 #define MLX5_FS_DEFAULT_FLOW_TAG 0x0
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/lib/fw.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/fw.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/fw.c
index 5718aada6605..7371ae07735c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/fw.c
@@ -30,10 +30,10 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
+#include "lib/driver.h"
+#include "lib/cmd.h"
 #include <linux/module.h>
-#include "mlx5_core.h"
+#include "mlx5.h"
 
 static int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev, u32 *out,
 				  int outlen)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mad.c b/drivers/net/ethernet/mellanox/mlx5/lib/mad.c
similarity index 96%
rename from drivers/net/ethernet/mellanox/mlx5/core/mad.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/mad.c
index 3a3b0005fd2b..6c8572624d2e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mad.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/mad.c
@@ -32,9 +32,9 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 
 int mlx5_core_mad_ifc(struct mlx5_core_dev *dev, const void *inb, void *outb,
 		      u16 opmod, u8 port)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mcg.c b/drivers/net/ethernet/mellanox/mlx5/lib/mcg.c
similarity index 96%
rename from drivers/net/ethernet/mellanox/mlx5/core/mcg.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/mcg.c
index ba2b09cc192f..e231aa4f5286 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/mcg.c
@@ -32,10 +32,10 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
+#include "lib/driver.h"
+#include "lib/cmd.h"
 #include <rdma/ib_verbs.h>
-#include "mlx5_core.h"
+#include "mlx5.h"
 
 int mlx5_core_attach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn)
 {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/drivers/net/ethernet/mellanox/mlx5/lib/mlx5_ifc.h
similarity index 100%
rename from include/linux/mlx5/mlx5_ifc.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/mlx5_ifc.h
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mr.c b/drivers/net/ethernet/mellanox/mlx5/lib/mr.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/mr.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/mr.c
index b9736f505bdf..f5eb1205c612 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/mr.c
@@ -32,9 +32,9 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 
 void mlx5_init_mkey_table(struct mlx5_core_dev *dev)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pd.c b/drivers/net/ethernet/mellanox/mlx5/lib/pd.c
similarity index 96%
rename from drivers/net/ethernet/mellanox/mlx5/core/pd.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/pd.c
index bd830d8d6c5f..1a55fc346fda 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/pd.c
@@ -32,9 +32,9 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 
 int mlx5_core_alloc_pd(struct mlx5_core_dev *dev, u32 *pdn)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/lib/port.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/port.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/port.c
index d2ec9d232a70..d6bb70d36149 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/port.c
@@ -31,10 +31,10 @@
  */
 
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/port.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/port.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 
 int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 			 int size_in, void *data_out, int size_out,
diff --git a/include/linux/mlx5/port.h b/drivers/net/ethernet/mellanox/mlx5/lib/port.h
similarity index 99%
rename from include/linux/mlx5/port.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/port.h
index e527732fb31b..f9fff1710d05 100644
--- a/include/linux/mlx5/port.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/port.h
@@ -33,7 +33,7 @@
 #ifndef __MLX5_PORT_H__
 #define __MLX5_PORT_H__
 
-#include <linux/mlx5/driver.h>
+#include "driver.h"
 
 enum mlx5_beacon_duration {
 	MLX5_BEACON_DURATION_OFF = 0x0,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/lib/qp.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/qp.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/qp.c
index cbbcef2884be..9dcc3b47d1a9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/qp.c
@@ -33,12 +33,11 @@
 
 #include <linux/gfp.h>
 #include <linux/export.h>
-#include <linux/mlx5/cmd.h>
-#include <linux/mlx5/qp.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/transobj.h>
-
-#include "mlx5_core.h"
+#include "lib/cmd.h"
+#include "lib/qp.h"
+#include "lib/driver.h"
+#include "lib/transobj.h"
+#include "mlx5.h"
 
 static struct mlx5_core_rsc_common *mlx5_get_rsc(struct mlx5_core_dev *dev,
 						 u32 rsn)
diff --git a/include/linux/mlx5/qp.h b/drivers/net/ethernet/mellanox/mlx5/lib/qp.h
similarity index 99%
rename from include/linux/mlx5/qp.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/qp.h
index 219c699c17b7..a161d697e3b2 100644
--- a/include/linux/mlx5/qp.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/qp.h
@@ -33,8 +33,8 @@
 #ifndef MLX5_QP_H
 #define MLX5_QP_H
 
-#include <linux/mlx5/device.h>
-#include <linux/mlx5/driver.h>
+#include "lib/device.h"
+#include "lib/driver.h"
 
 #define MLX5_INVALID_LKEY	0x100
 #define MLX5_SIG_WQE_SIZE	(MLX5_SEND_WQE_BB * 5)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/rl.c b/drivers/net/ethernet/mellanox/mlx5/lib/rl.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/rl.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/rl.c
index e651e4c02867..796c7e626d0c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/rl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/rl.c
@@ -32,9 +32,9 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 
 /* Scheduling element fw management */
 int mlx5_create_scheduling_element_cmd(struct mlx5_core_dev *dev, u8 hierarchy,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/srq.c b/drivers/net/ethernet/mellanox/mlx5/lib/srq.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/srq.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/srq.c
index 3099630015d7..5be9bc5320aa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/srq.c
@@ -32,12 +32,12 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include <linux/mlx5/srq.h>
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "lib/srq.h"
 #include <rdma/ib_verbs.h>
-#include "mlx5_core.h"
-#include <linux/mlx5/transobj.h>
+#include "mlx5.h"
+#include "lib/transobj.h"
 
 void mlx5_srq_event(struct mlx5_core_dev *dev, u32 srqn, int event_type)
 {
diff --git a/include/linux/mlx5/srq.h b/drivers/net/ethernet/mellanox/mlx5/lib/srq.h
similarity index 98%
rename from include/linux/mlx5/srq.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/srq.h
index 1cde0fd53f90..8bbc5170d5fa 100644
--- a/include/linux/mlx5/srq.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/srq.h
@@ -33,7 +33,7 @@
 #ifndef MLX5_SRQ_H
 #define MLX5_SRQ_H
 
-#include <linux/mlx5/driver.h>
+#include "lib/driver.h"
 
 enum {
 	MLX5_SRQ_FLAG_ERR    = (1 << 0),
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/lib/transobj.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/transobj.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/transobj.c
index a00ff49eec18..e7ebe20d4217 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/transobj.c
@@ -30,9 +30,9 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx5/driver.h>
-#include "mlx5_core.h"
-#include <linux/mlx5/transobj.h>
+#include "lib/driver.h"
+#include "mlx5.h"
+#include "lib/transobj.h"
 
 int mlx5_core_alloc_transport_domain(struct mlx5_core_dev *dev, u32 *tdn)
 {
diff --git a/include/linux/mlx5/transobj.h b/drivers/net/ethernet/mellanox/mlx5/lib/transobj.h
similarity index 99%
rename from include/linux/mlx5/transobj.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/transobj.h
index 88441f5ece25..3cf24bce8a5c 100644
--- a/include/linux/mlx5/transobj.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/transobj.h
@@ -33,7 +33,7 @@
 #ifndef __TRANSOBJ_H__
 #define __TRANSOBJ_H__
 
-#include <linux/mlx5/driver.h>
+#include "lib/driver.h"
 
 int mlx5_core_alloc_transport_domain(struct mlx5_core_dev *dev, u32 *tdn);
 void mlx5_core_dealloc_transport_domain(struct mlx5_core_dev *dev, u32 tdn);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/lib/uar.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/uar.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/uar.c
index 2e6b0f290ddc..1e4a8396450b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/uar.c
@@ -33,9 +33,9 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/io-mapping.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 
 int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/lib/vport.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/vport.c
rename to drivers/net/ethernet/mellanox/mlx5/lib/vport.c
index 269e4401c342..beb3f8d9991a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/vport.c
@@ -32,9 +32,9 @@
 
 #include <linux/export.h>
 #include <linux/etherdevice.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/vport.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/vport.h"
+#include "mlx5.h"
 
 static int _mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod,
 				   u16 vport, u32 *out, int outlen)
diff --git a/include/linux/mlx5/vport.h b/drivers/net/ethernet/mellanox/mlx5/lib/vport.h
similarity index 98%
rename from include/linux/mlx5/vport.h
rename to drivers/net/ethernet/mellanox/mlx5/lib/vport.h
index ec35157ea725..c99cd27489d8 100644
--- a/include/linux/mlx5/vport.h
+++ b/drivers/net/ethernet/mellanox/mlx5/lib/vport.h
@@ -33,8 +33,8 @@
 #ifndef __MLX5_VPORT_H__
 #define __MLX5_VPORT_H__
 
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/device.h>
+#include "lib/driver.h"
+#include "lib/device.h"
 
 enum {
 	MLX5_CAP_INLINE_MODE_L2,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/main.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/main.c
rename to drivers/net/ethernet/mellanox/mlx5/main.c
index a16ee1603272..dd7e3904f094 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/main.c
@@ -40,21 +40,21 @@
 #include <linux/io-mapping.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cq.h>
-#include <linux/mlx5/qp.h>
-#include <linux/mlx5/srq.h>
+#include "lib/driver.h"
+#include "lib/cq.h"
+#include "lib/qp.h"
+#include "lib/srq.h"
 #include <linux/debugfs.h>
 #include <linux/kmod.h>
-#include <linux/mlx5/mlx5_ifc.h>
+#include "lib/mlx5_ifc.h"
 #ifdef CONFIG_RFS_ACCEL
 #include <linux/cpu_rmap.h>
 #endif
 #include <net/devlink.h>
-#include "mlx5_core.h"
-#include "fs_core.h"
+#include "mlx5.h"
+#include "fs/core.h"
 #ifdef CONFIG_MLX5_CORE_EN
-#include "eswitch.h"
+#include "sriov/eswitch.h"
 #endif
 
 MODULE_AUTHOR("Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>");
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/mlx5.h
similarity index 100%
rename from drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
rename to drivers/net/ethernet/mellanox/mlx5/mlx5.h
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/pagealloc.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
rename to drivers/net/ethernet/mellanox/mlx5/pagealloc.c
index a57d5a81eb05..914616fb4767 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/pagealloc.c
@@ -34,9 +34,9 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/delay.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/cmd.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "lib/cmd.h"
+#include "mlx5.h"
 
 enum {
 	MLX5_PAGES_CANT_GIVE	= 0,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/sriov/eswitch.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
rename to drivers/net/ethernet/mellanox/mlx5/sriov/eswitch.c
index d6807c3cc461..378fd344bf63 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/sriov/eswitch.c
@@ -31,12 +31,12 @@
  */
 
 #include <linux/etherdevice.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/mlx5_ifc.h>
-#include <linux/mlx5/vport.h>
-#include <linux/mlx5/fs.h>
-#include "mlx5_core.h"
-#include "eswitch.h"
+#include "lib/driver.h"
+#include "lib/mlx5_ifc.h"
+#include "lib/vport.h"
+#include "lib/fs.h"
+#include "mlx5.h"
+#include "sriov/eswitch.h"
 
 #define UPLINK_VPORT 0xFFFF
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/sriov/eswitch.h
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
rename to drivers/net/ethernet/mellanox/mlx5/sriov/eswitch.h
index 8661dd3f542c..9840fd1392ea 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/sriov/eswitch.h
@@ -36,7 +36,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_link.h>
 #include <net/devlink.h>
-#include <linux/mlx5/device.h>
+#include "lib/device.h"
 
 #define MLX5_MAX_UC_PER_VPORT(dev) \
 	(1 << MLX5_CAP_GEN(dev, log_max_current_uc_list))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/sriov/eswitch_offloads.c
similarity index 99%
rename from drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
rename to drivers/net/ethernet/mellanox/mlx5/sriov/eswitch_offloads.c
index 466e161010f7..d09b2f8efc9a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/sriov/eswitch_offloads.c
@@ -31,12 +31,12 @@
  */
 
 #include <linux/etherdevice.h>
-#include <linux/mlx5/driver.h>
-#include <linux/mlx5/mlx5_ifc.h>
-#include <linux/mlx5/vport.h>
-#include <linux/mlx5/fs.h>
-#include "mlx5_core.h"
-#include "eswitch.h"
+#include "lib/driver.h"
+#include "lib/mlx5_ifc.h"
+#include "lib/vport.h"
+#include "lib/fs.h"
+#include "mlx5.h"
+#include "sriov/eswitch.h"
 
 enum {
 	FDB_FAST_PATH = 0,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/sriov/sriov.c
similarity index 98%
rename from drivers/net/ethernet/mellanox/mlx5/core/sriov.c
rename to drivers/net/ethernet/mellanox/mlx5/sriov/sriov.c
index e08627785590..1d8c09712c5b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/sriov/sriov.c
@@ -31,10 +31,10 @@
  */
 
 #include <linux/pci.h>
-#include <linux/mlx5/driver.h>
-#include "mlx5_core.h"
+#include "lib/driver.h"
+#include "mlx5.h"
 #ifdef CONFIG_MLX5_CORE_EN
-#include "eswitch.h"
+#include "sriov/eswitch.h"
 #endif
 
 bool mlx5_sriov_is_enabled(struct mlx5_core_dev *dev)
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
