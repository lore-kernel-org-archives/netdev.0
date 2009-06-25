From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] Consolidate shared code between enic and fnic drivers.
Date: Thu, 25 Jun 2009 09:38:03 -0700
Message-ID: <adaprcsjml0.fsf@cisco.com>
References: <C65FC516.7747%scofeldm@cisco.com> <4A3A7D4B.5050204@cs.wisc.edu>
	<adazlbyoe7l.fsf@cisco.com> <4A416B02.2040607@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>,
	Scott Feldman <scofeldm@cisco.com>,
	Hannes Reinecke <hare@suse.de>,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net,
	gospo@redhat.com, abjoglek@cisco.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Joe Eykholt <jeykholt@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4A416B02.2040607@cisco.com> (Joe Eykholt's message of "Tue, 23
	Jun 2009 16:53:38 -0700")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > Or how about include/drivers/mlx4 and similarly for cisco_vnic
 > (but we're leaning towards cvnic)?
 > 
 > include/drivers seems more like a generally useful subdirectory
 > with some meaning.   include/shared leaves one guessing as to what
 > it might be.

Makes sense... here's a first stab at a patch to move the mlx4_core
module into drivers/shared and include/drivers (as a git patch, to make
the renames not create thousands of lines of "delete one file, create
the same contents somewhere else").  Comments welcome -- does this seem
like something worth doing to people?

NOT-Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/Kconfig                            |    2 +
 drivers/Makefile                           |    2 +
 drivers/infiniband/hw/mlx4/cq.c            |    4 +-
 drivers/infiniband/hw/mlx4/mad.c           |    2 +-
 drivers/infiniband/hw/mlx4/main.c          |    4 +-
 drivers/infiniband/hw/mlx4/mlx4_ib.h       |    4 +-
 drivers/infiniband/hw/mlx4/qp.c            |    2 +-
 drivers/infiniband/hw/mlx4/srq.c           |    4 +-
 drivers/net/Kconfig                        |   15 ------------
 drivers/net/Makefile                       |    2 +-
 drivers/net/mlx4/Makefile                  |    5 ----
 drivers/net/mlx4/en_cq.c                   |    6 ++--
 drivers/net/mlx4/en_main.c                 |    6 ++--
 drivers/net/mlx4/en_netdev.c               |    8 +++---
 drivers/net/mlx4/en_port.c                 |    4 +-
 drivers/net/mlx4/en_resources.c            |    2 +-
 drivers/net/mlx4/en_rx.c                   |    4 +-
 drivers/net/mlx4/en_tx.c                   |    4 +-
 drivers/net/mlx4/mlx4_en.h                 |   10 ++++----
 drivers/shared/Kconfig                     |   34 ++++++++++++++++++++++++++++
 drivers/shared/Makefile                    |    1 +
 drivers/shared/mlx4/Makefile               |    4 +++
 drivers/{net => shared}/mlx4/alloc.c       |    0
 drivers/{net => shared}/mlx4/catas.c       |    0
 drivers/{net => shared}/mlx4/cmd.c         |    2 +-
 drivers/{net => shared}/mlx4/cq.c          |    4 +-
 drivers/{net => shared}/mlx4/eq.c          |    2 +-
 drivers/{net => shared}/mlx4/fw.c          |    2 +-
 drivers/{net => shared}/mlx4/fw.h          |    0
 drivers/{net => shared}/mlx4/icm.c         |    2 +-
 drivers/{net => shared}/mlx4/icm.h         |    0
 drivers/{net => shared}/mlx4/intf.c        |    0
 drivers/{net => shared}/mlx4/main.c        |    4 +-
 drivers/{net => shared}/mlx4/mcg.c         |    2 +-
 drivers/{net => shared}/mlx4/mlx4.h        |    6 ++--
 drivers/{net => shared}/mlx4/mr.c          |    2 +-
 drivers/{net => shared}/mlx4/pd.c          |    0
 drivers/{net => shared}/mlx4/port.c        |    2 +-
 drivers/{net => shared}/mlx4/profile.c     |    0
 drivers/{net => shared}/mlx4/qp.c          |    4 +-
 drivers/{net => shared}/mlx4/reset.c       |    0
 drivers/{net => shared}/mlx4/sense.c       |    2 +-
 drivers/{net => shared}/mlx4/srq.c         |    2 +-
 include/{linux => drivers}/mlx4/cmd.h      |    0
 include/{linux => drivers}/mlx4/cq.h       |    4 +-
 include/{linux => drivers}/mlx4/device.h   |    0
 include/{linux => drivers}/mlx4/doorbell.h |    0
 include/{linux => drivers}/mlx4/driver.h   |    0
 include/{linux => drivers}/mlx4/qp.h       |    2 +-
 include/{linux => drivers}/mlx4/srq.h      |    0
 50 files changed, 97 insertions(+), 74 deletions(-)
 create mode 100644 drivers/shared/Kconfig
 create mode 100644 drivers/shared/Makefile
 create mode 100644 drivers/shared/mlx4/Makefile
 rename drivers/{net => shared}/mlx4/alloc.c (100%)
 rename drivers/{net => shared}/mlx4/catas.c (100%)
 rename drivers/{net => shared}/mlx4/cmd.c (99%)
 rename drivers/{net => shared}/mlx4/cq.c (99%)
 rename drivers/{net => shared}/mlx4/eq.c (99%)
 rename drivers/{net => shared}/mlx4/fw.c (99%)
 rename drivers/{net => shared}/mlx4/fw.h (100%)
 rename drivers/{net => shared}/mlx4/icm.c (99%)
 rename drivers/{net => shared}/mlx4/icm.h (100%)
 rename drivers/{net => shared}/mlx4/intf.c (100%)
 rename drivers/{net => shared}/mlx4/main.c (99%)
 rename drivers/{net => shared}/mlx4/mcg.c (99%)
 rename drivers/{net => shared}/mlx4/mlx4.h (99%)
 rename drivers/{net => shared}/mlx4/mr.c (99%)
 rename drivers/{net => shared}/mlx4/pd.c (100%)
 rename drivers/{net => shared}/mlx4/port.c (99%)
 rename drivers/{net => shared}/mlx4/profile.c (100%)
 rename drivers/{net => shared}/mlx4/qp.c (99%)
 rename drivers/{net => shared}/mlx4/reset.c (100%)
 rename drivers/{net => shared}/mlx4/sense.c (99%)
 rename drivers/{net => shared}/mlx4/srq.c (99%)
 rename include/{linux => drivers}/mlx4/cmd.h (100%)
 rename include/{linux => drivers}/mlx4/cq.h (98%)
 rename include/{linux => drivers}/mlx4/device.h (100%)
 rename include/{linux => drivers}/mlx4/doorbell.h (100%)
 rename include/{linux => drivers}/mlx4/driver.h (100%)
 rename include/{linux => drivers}/mlx4/qp.h (99%)
 rename include/{linux => drivers}/mlx4/srq.h (100%)

diff --git a/drivers/Kconfig b/drivers/Kconfig
index 48bbdbe..b88b3bf 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -113,4 +113,6 @@ source "drivers/xen/Kconfig"
 source "drivers/staging/Kconfig"
 
 source "drivers/platform/Kconfig"
+
+source "drivers/shared/Kconfig"
 endmenu
diff --git a/drivers/Makefile b/drivers/Makefile
index bc4205d..15e9ceb 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -21,6 +21,8 @@ obj-$(CONFIG_XEN)		+= xen/
 # regulators early, since some subsystems rely on them to initialize
 obj-$(CONFIG_REGULATOR)		+= regulator/
 
+obj-y				+= shared/
+
 # char/ comes before serial/ etc so that the VT console is the boot-time
 # default.
 obj-y				+= char/
diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index de5263b..6df07ce 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -31,8 +31,8 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx4/cq.h>
-#include <linux/mlx4/qp.h>
+#include <drivers/mlx4/cq.h>
+#include <drivers/mlx4/qp.h>
 
 #include "mlx4_ib.h"
 #include "user.h"
diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 19e68ab..5699a02 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -33,7 +33,7 @@
 #include <rdma/ib_mad.h>
 #include <rdma/ib_smi.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4_ib.h"
 
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index ae3d759..ed5c018 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -38,8 +38,8 @@
 #include <rdma/ib_smi.h>
 #include <rdma/ib_user_verbs.h>
 
-#include <linux/mlx4/driver.h>
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/driver.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4_ib.h"
 #include "user.h"
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 8a7dd67..d853527 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -41,8 +41,8 @@
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_umem.h>
 
-#include <linux/mlx4/device.h>
-#include <linux/mlx4/doorbell.h>
+#include <drivers/mlx4/device.h>
+#include <drivers/mlx4/doorbell.h>
 
 struct mlx4_ib_ucontext {
 	struct ib_ucontext	ibucontext;
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index c4a0264..2523194 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -36,7 +36,7 @@
 #include <rdma/ib_cache.h>
 #include <rdma/ib_pack.h>
 
-#include <linux/mlx4/qp.h>
+#include <drivers/mlx4/qp.h>
 
 #include "mlx4_ib.h"
 #include "user.h"
diff --git a/drivers/infiniband/hw/mlx4/srq.c b/drivers/infiniband/hw/mlx4/srq.c
index d425652..9ac59e9 100644
--- a/drivers/infiniband/hw/mlx4/srq.c
+++ b/drivers/infiniband/hw/mlx4/srq.c
@@ -31,8 +31,8 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx4/qp.h>
-#include <linux/mlx4/srq.h>
+#include <drivers/mlx4/qp.h>
+#include <drivers/mlx4/srq.h>
 
 #include "mlx4_ib.h"
 #include "user.h"
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c155bd3..cb99ed9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2688,21 +2688,6 @@ config MLX4_EN
 	  This driver supports Mellanox Technologies ConnectX Ethernet
 	  devices.
 
-config MLX4_CORE
-	tristate
-	depends on PCI
-	default n
-
-config MLX4_DEBUG
-	bool "Verbose debugging output" if (MLX4_CORE && EMBEDDED)
-	depends on MLX4_CORE
-	default y
-	---help---
-	  This option causes debugging code to be compiled into the
-	  mlx4_core driver.  The output can be turned on via the
-	  debug_level module parameter (which can also be set after
-	  the driver is loaded through sysfs).
-
 config TEHUTI
 	tristate "Tehuti Networks 10G Ethernet"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4b58a59..a97f8be 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -237,7 +237,7 @@ obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
 pasemi_mac_driver-objs := pasemi_mac.o pasemi_mac_ethtool.o
-obj-$(CONFIG_MLX4_CORE) += mlx4/
+obj-$(CONFIG_MLX4_EN) += mlx4/
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 
diff --git a/drivers/net/mlx4/Makefile b/drivers/net/mlx4/Makefile
index 1fd068e..b699e36 100644
--- a/drivers/net/mlx4/Makefile
+++ b/drivers/net/mlx4/Makefile
@@ -1,8 +1,3 @@
-obj-$(CONFIG_MLX4_CORE)		+= mlx4_core.o
-
-mlx4_core-y :=	alloc.o catas.o cmd.o cq.o eq.o fw.o icm.o intf.o main.o mcg.o \
-		mr.o pd.o port.o profile.o qp.o reset.o sense.o srq.o
-
 obj-$(CONFIG_MLX4_EN)               += mlx4_en.o
 
 mlx4_en-y := 	en_main.o en_tx.o en_rx.o en_ethtool.o en_port.o en_cq.o \
diff --git a/drivers/net/mlx4/en_cq.c b/drivers/net/mlx4/en_cq.c
index 21786ad..4031782 100644
--- a/drivers/net/mlx4/en_cq.c
+++ b/drivers/net/mlx4/en_cq.c
@@ -31,9 +31,9 @@
  *
  */
 
-#include <linux/mlx4/cq.h>
-#include <linux/mlx4/qp.h>
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cq.h>
+#include <drivers/mlx4/qp.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4_en.h"
 
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 9ed4a15..181535b 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -36,9 +36,9 @@
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 
-#include <linux/mlx4/driver.h>
-#include <linux/mlx4/device.h>
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/driver.h>
+#include <drivers/mlx4/device.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4_en.h"
 
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 93f4abd..e0d3be0 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -36,10 +36,10 @@
 #include <linux/if_vlan.h>
 #include <linux/delay.h>
 
-#include <linux/mlx4/driver.h>
-#include <linux/mlx4/device.h>
-#include <linux/mlx4/cmd.h>
-#include <linux/mlx4/cq.h>
+#include <drivers/mlx4/driver.h>
+#include <drivers/mlx4/device.h>
+#include <drivers/mlx4/cmd.h>
+#include <drivers/mlx4/cq.h>
 
 #include "mlx4_en.h"
 #include "en_port.h"
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index a29abe8..07aa02d 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -34,8 +34,8 @@
 
 #include <linux/if_vlan.h>
 
-#include <linux/mlx4/device.h>
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/device.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "en_port.h"
 #include "mlx4_en.h"
diff --git a/drivers/net/mlx4/en_resources.c b/drivers/net/mlx4/en_resources.c
index 65ca706..8c5d6ff 100644
--- a/drivers/net/mlx4/en_resources.c
+++ b/drivers/net/mlx4/en_resources.c
@@ -32,7 +32,7 @@
  */
 
 #include <linux/vmalloc.h>
-#include <linux/mlx4/qp.h>
+#include <drivers/mlx4/qp.h>
 
 #include "mlx4_en.h"
 
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 91bdfdf..705f8ab 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -31,8 +31,8 @@
  *
  */
 
-#include <linux/mlx4/cq.h>
-#include <linux/mlx4/qp.h>
+#include <drivers/mlx4/cq.h>
+#include <drivers/mlx4/qp.h>
 #include <linux/skbuff.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 08c43f2..ce56a87 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -32,8 +32,8 @@
  */
 
 #include <asm/page.h>
-#include <linux/mlx4/cq.h>
-#include <linux/mlx4/qp.h>
+#include <drivers/mlx4/cq.h>
+#include <drivers/mlx4/qp.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <linux/vmalloc.h>
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index c7c5e86..349a634 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -40,11 +40,11 @@
 #include <linux/netdevice.h>
 #include <linux/inet_lro.h>
 
-#include <linux/mlx4/device.h>
-#include <linux/mlx4/qp.h>
-#include <linux/mlx4/cq.h>
-#include <linux/mlx4/srq.h>
-#include <linux/mlx4/doorbell.h>
+#include <drivers/mlx4/device.h>
+#include <drivers/mlx4/qp.h>
+#include <drivers/mlx4/cq.h>
+#include <drivers/mlx4/srq.h>
+#include <drivers/mlx4/doorbell.h>
 
 #include "en_port.h"
 
diff --git a/drivers/shared/Kconfig b/drivers/shared/Kconfig
new file mode 100644
index 0000000..5e6ea3c
--- /dev/null
+++ b/drivers/shared/Kconfig
@@ -0,0 +1,34 @@
+#
+# Drivers that arbitrate shared access to multi-function hardware
+#
+
+#
+# Main options are selected by client modules that really use the
+# hardware, and are not exposed to the user to choose
+#
+
+config MLX4_CORE
+	tristate
+	depends on PCI
+	default n
+
+menuconfig SHARED_DEVICES
+	bool "Shared device arbitration driver options"
+	---help---
+	  Some devices can be used simultaneously as an Ethernet NIC
+	  and a Fibre Channel-over-Ethernet HBA, with separate NIC and
+	  HBA drivers that both use a common low-level driver to
+	  arbitrate shared access to the common hardware.  Say Y here
+	  to get to see options for the low-level arbitration drivers.
+
+	  If in doubt, say N.
+
+config MLX4_DEBUG
+	bool "mlx4_core verbose debugging output" if (MLX4_CORE && SHARED_DEVICES)
+	depends on MLX4_CORE
+	default y
+	---help---
+	  This option causes debugging code to be compiled into the
+	  mlx4_core driver.  The output can be turned on via the
+	  debug_level module parameter (which can also be set after
+	  the driver is loaded through sysfs).
diff --git a/drivers/shared/Makefile b/drivers/shared/Makefile
new file mode 100644
index 0000000..42c840e
--- /dev/null
+++ b/drivers/shared/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_MLX4_CORE) += mlx4/
diff --git a/drivers/shared/mlx4/Makefile b/drivers/shared/mlx4/Makefile
new file mode 100644
index 0000000..bdae863
--- /dev/null
+++ b/drivers/shared/mlx4/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_MLX4_CORE)		+= mlx4_core.o
+
+mlx4_core-y :=	alloc.o catas.o cmd.o cq.o eq.o fw.o icm.o intf.o main.o mcg.o \
+		mr.o pd.o port.o profile.o qp.o reset.o sense.o srq.o
diff --git a/drivers/net/mlx4/alloc.c b/drivers/shared/mlx4/alloc.c
similarity index 100%
rename from drivers/net/mlx4/alloc.c
rename to drivers/shared/mlx4/alloc.c
diff --git a/drivers/net/mlx4/catas.c b/drivers/shared/mlx4/catas.c
similarity index 100%
rename from drivers/net/mlx4/catas.c
rename to drivers/shared/mlx4/catas.c
diff --git a/drivers/net/mlx4/cmd.c b/drivers/shared/mlx4/cmd.c
similarity index 99%
rename from drivers/net/mlx4/cmd.c
rename to drivers/shared/mlx4/cmd.c
index 2845a05..5d9342d 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/shared/mlx4/cmd.c
@@ -36,7 +36,7 @@
 #include <linux/pci.h>
 #include <linux/errno.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include <asm/io.h>
 
diff --git a/drivers/net/mlx4/cq.c b/drivers/shared/mlx4/cq.c
similarity index 99%
rename from drivers/net/mlx4/cq.c
rename to drivers/shared/mlx4/cq.c
index ac57b6a..07313cb 100644
--- a/drivers/net/mlx4/cq.c
+++ b/drivers/shared/mlx4/cq.c
@@ -37,8 +37,8 @@
 #include <linux/init.h>
 #include <linux/hardirq.h>
 
-#include <linux/mlx4/cmd.h>
-#include <linux/mlx4/cq.h>
+#include <drivers/mlx4/cmd.h>
+#include <drivers/mlx4/cq.h>
 
 #include "mlx4.h"
 #include "icm.h"
diff --git a/drivers/net/mlx4/eq.c b/drivers/shared/mlx4/eq.c
similarity index 99%
rename from drivers/net/mlx4/eq.c
rename to drivers/shared/mlx4/eq.c
index b9ceddd..828fccd 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/shared/mlx4/eq.c
@@ -36,7 +36,7 @@
 #include <linux/mm.h>
 #include <linux/dma-mapping.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4.h"
 #include "fw.h"
diff --git a/drivers/net/mlx4/fw.c b/drivers/shared/mlx4/fw.c
similarity index 99%
rename from drivers/net/mlx4/fw.c
rename to drivers/shared/mlx4/fw.c
index cee199c..c967f46 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/shared/mlx4/fw.c
@@ -32,7 +32,7 @@
  * SOFTWARE.
  */
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "fw.h"
 #include "icm.h"
diff --git a/drivers/net/mlx4/fw.h b/drivers/shared/mlx4/fw.h
similarity index 100%
rename from drivers/net/mlx4/fw.h
rename to drivers/shared/mlx4/fw.h
diff --git a/drivers/net/mlx4/icm.c b/drivers/shared/mlx4/icm.c
similarity index 99%
rename from drivers/net/mlx4/icm.c
rename to drivers/shared/mlx4/icm.c
index baf4bf6..1e7dcc0 100644
--- a/drivers/net/mlx4/icm.c
+++ b/drivers/shared/mlx4/icm.c
@@ -36,7 +36,7 @@
 #include <linux/mm.h>
 #include <linux/scatterlist.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4.h"
 #include "icm.h"
diff --git a/drivers/net/mlx4/icm.h b/drivers/shared/mlx4/icm.h
similarity index 100%
rename from drivers/net/mlx4/icm.h
rename to drivers/shared/mlx4/icm.h
diff --git a/drivers/net/mlx4/intf.c b/drivers/shared/mlx4/intf.c
similarity index 100%
rename from drivers/net/mlx4/intf.c
rename to drivers/shared/mlx4/intf.c
diff --git a/drivers/net/mlx4/main.c b/drivers/shared/mlx4/main.c
similarity index 99%
rename from drivers/net/mlx4/main.c
rename to drivers/shared/mlx4/main.c
index 018348c..c37340c 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/shared/mlx4/main.c
@@ -39,8 +39,8 @@
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
 
-#include <linux/mlx4/device.h>
-#include <linux/mlx4/doorbell.h>
+#include <drivers/mlx4/device.h>
+#include <drivers/mlx4/doorbell.h>
 
 #include "mlx4.h"
 #include "fw.h"
diff --git a/drivers/net/mlx4/mcg.c b/drivers/shared/mlx4/mcg.c
similarity index 99%
rename from drivers/net/mlx4/mcg.c
rename to drivers/shared/mlx4/mcg.c
index 6053c35..d8cf9f5 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/shared/mlx4/mcg.c
@@ -35,7 +35,7 @@
 #include <linux/string.h>
 #include <linux/slab.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4.h"
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/shared/mlx4/mlx4.h
similarity index 99%
rename from drivers/net/mlx4/mlx4.h
rename to drivers/shared/mlx4/mlx4.h
index 5bd79c2..64c7c82 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/shared/mlx4/mlx4.h
@@ -42,9 +42,9 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 
-#include <linux/mlx4/device.h>
-#include <linux/mlx4/driver.h>
-#include <linux/mlx4/doorbell.h>
+#include <drivers/mlx4/device.h>
+#include <drivers/mlx4/driver.h>
+#include <drivers/mlx4/doorbell.h>
 
 #define DRV_NAME	"mlx4_core"
 #define PFX		DRV_NAME ": "
diff --git a/drivers/net/mlx4/mr.c b/drivers/shared/mlx4/mr.c
similarity index 99%
rename from drivers/net/mlx4/mr.c
rename to drivers/shared/mlx4/mr.c
index f96948b..9a7e799 100644
--- a/drivers/net/mlx4/mr.c
+++ b/drivers/shared/mlx4/mr.c
@@ -35,7 +35,7 @@
 #include <linux/init.h>
 #include <linux/errno.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4.h"
 #include "icm.h"
diff --git a/drivers/net/mlx4/pd.c b/drivers/shared/mlx4/pd.c
similarity index 100%
rename from drivers/net/mlx4/pd.c
rename to drivers/shared/mlx4/pd.c
diff --git a/drivers/net/mlx4/port.c b/drivers/shared/mlx4/port.c
similarity index 99%
rename from drivers/net/mlx4/port.c
rename to drivers/shared/mlx4/port.c
index 606aa58..260c87d 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/shared/mlx4/port.c
@@ -33,7 +33,7 @@
 #include <linux/errno.h>
 #include <linux/if_ether.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4.h"
 
diff --git a/drivers/net/mlx4/profile.c b/drivers/shared/mlx4/profile.c
similarity index 100%
rename from drivers/net/mlx4/profile.c
rename to drivers/shared/mlx4/profile.c
diff --git a/drivers/net/mlx4/qp.c b/drivers/shared/mlx4/qp.c
similarity index 99%
rename from drivers/net/mlx4/qp.c
rename to drivers/shared/mlx4/qp.c
index 1c565ef..4595047 100644
--- a/drivers/net/mlx4/qp.c
+++ b/drivers/shared/mlx4/qp.c
@@ -35,8 +35,8 @@
 
 #include <linux/init.h>
 
-#include <linux/mlx4/cmd.h>
-#include <linux/mlx4/qp.h>
+#include <drivers/mlx4/cmd.h>
+#include <drivers/mlx4/qp.h>
 
 #include "mlx4.h"
 #include "icm.h"
diff --git a/drivers/net/mlx4/reset.c b/drivers/shared/mlx4/reset.c
similarity index 100%
rename from drivers/net/mlx4/reset.c
rename to drivers/shared/mlx4/reset.c
diff --git a/drivers/net/mlx4/sense.c b/drivers/shared/mlx4/sense.c
similarity index 99%
rename from drivers/net/mlx4/sense.c
rename to drivers/shared/mlx4/sense.c
index f36ae69..03638fd 100644
--- a/drivers/net/mlx4/sense.c
+++ b/drivers/shared/mlx4/sense.c
@@ -34,7 +34,7 @@
 #include <linux/errno.h>
 #include <linux/if_ether.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4.h"
 
diff --git a/drivers/net/mlx4/srq.c b/drivers/shared/mlx4/srq.c
similarity index 99%
rename from drivers/net/mlx4/srq.c
rename to drivers/shared/mlx4/srq.c
index fe9f218..898afab 100644
--- a/drivers/net/mlx4/srq.c
+++ b/drivers/shared/mlx4/srq.c
@@ -33,7 +33,7 @@
 
 #include <linux/init.h>
 
-#include <linux/mlx4/cmd.h>
+#include <drivers/mlx4/cmd.h>
 
 #include "mlx4.h"
 #include "icm.h"
diff --git a/include/linux/mlx4/cmd.h b/include/drivers/mlx4/cmd.h
similarity index 100%
rename from include/linux/mlx4/cmd.h
rename to include/drivers/mlx4/cmd.h
diff --git a/include/linux/mlx4/cq.h b/include/drivers/mlx4/cq.h
similarity index 98%
rename from include/linux/mlx4/cq.h
rename to include/drivers/mlx4/cq.h
index 6f65b2c..9883a89 100644
--- a/include/linux/mlx4/cq.h
+++ b/include/drivers/mlx4/cq.h
@@ -35,8 +35,8 @@
 
 #include <linux/types.h>
 
-#include <linux/mlx4/device.h>
-#include <linux/mlx4/doorbell.h>
+#include <drivers/mlx4/device.h>
+#include <drivers/mlx4/doorbell.h>
 
 struct mlx4_cqe {
 	__be32			vlan_my_qpn;
diff --git a/include/linux/mlx4/device.h b/include/drivers/mlx4/device.h
similarity index 100%
rename from include/linux/mlx4/device.h
rename to include/drivers/mlx4/device.h
diff --git a/include/linux/mlx4/doorbell.h b/include/drivers/mlx4/doorbell.h
similarity index 100%
rename from include/linux/mlx4/doorbell.h
rename to include/drivers/mlx4/doorbell.h
diff --git a/include/linux/mlx4/driver.h b/include/drivers/mlx4/driver.h
similarity index 100%
rename from include/linux/mlx4/driver.h
rename to include/drivers/mlx4/driver.h
diff --git a/include/linux/mlx4/qp.h b/include/drivers/mlx4/qp.h
similarity index 99%
rename from include/linux/mlx4/qp.h
rename to include/drivers/mlx4/qp.h
index 9f29d86..30e40ac 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/drivers/mlx4/qp.h
@@ -35,7 +35,7 @@
 
 #include <linux/types.h>
 
-#include <linux/mlx4/device.h>
+#include <drivers/mlx4/device.h>
 
 #define MLX4_INVALID_LKEY	0x100
 
diff --git a/include/linux/mlx4/srq.h b/include/drivers/mlx4/srq.h
similarity index 100%
rename from include/linux/mlx4/srq.h
rename to include/drivers/mlx4/srq.h
-- 
1.6.3.1

