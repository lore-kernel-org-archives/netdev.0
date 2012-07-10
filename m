From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 8/9] net/eipoib: Add Makefile, Kconfig and MAINTAINERS entries
Date: Tue, 10 Jul 2012 15:16:08 +0300
Message-ID: <1341922569-4118-9-git-send-email-ogerlitz@mellanox.com>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:50389 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755384Ab2GJMQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:16:32 -0400
In-Reply-To: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

Add Kconfig entry under drivers/net and MAINTAINERS entry for eIPoIB, also
add the driver makefile.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 MAINTAINERS                 |    6 ++++++
 drivers/net/Kconfig         |   15 +++++++++++++++
 drivers/net/Makefile        |    1 +
 drivers/net/eipoib/Makefile |    4 ++++
 4 files changed, 26 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/eipoib/Makefile

diff --git a/MAINTAINERS b/MAINTAINERS
index 8da1373..582f8de 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2618,6 +2618,12 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ethernet/ibm/ehea/
 
+EIPoIB (Ethernet services over IPoIB) DRIVER
+M:	Erez Shitrit <erezsh@mellanox.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/eipoib/
+
 EMBEDDED LINUX
 M:	Paul Gortmaker <paul.gortmaker@windriver.com>
 M:	Matt Mackall <mpm@selenic.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0c2bd80..09c0352 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -68,6 +68,21 @@ config DUMMY
 	  To compile this driver as a module, choose M here: the module
 	  will be called dummy.
 
+config E_IPOIB
+        tristate "Ethernet Services over IPoIB"
+        depends on INFINIBAND_IPOIB
+       ---help---
+	  This driver supports Ethernet protocol over InfiniBand IPoIB devices.
+	  Some services can run only on top of Ethernet L2 interfaces, and
+	  cannot be bound to an IPoIB interface. With this new driver, these services 
+	  can run seamlessly.
+
+	  Main use case of the driver is the Ethernet Virtual Switching used in
+	  virtualized environments, where an eipoib netdevice can be used as a 
+	  Physical Interface (PIF) in the hypervisor domain, and allow other guests 
+	  Virtual Interfaces (VIF) connected to the same Virtual Switch to run over 
+	  the InfiniBand fabric.
+
 config EQUALIZER
 	tristate "EQL (serial line load balancing) support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3d375ca..2c3409e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_CAIF) += caif/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_ETRAX_ETHERNET) += cris/
 obj-$(CONFIG_NET_DSA) += dsa/
+obj-$(CONFIG_E_IPOIB) += eipoib/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_FDDI) += fddi/
 obj-$(CONFIG_HIPPI) += hippi/
diff --git a/drivers/net/eipoib/Makefile b/drivers/net/eipoib/Makefile
new file mode 100644
index 0000000..b64e96e
--- /dev/null
+++ b/drivers/net/eipoib/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_E_IPOIB)                         := eth_ipoib.o
+eth_ipoib-y                                    := eth_ipoib_main.o \
+                                                  eth_ipoib_sysfs.o \
+                                                  eth_ipoib_ethtool.o
-- 
1.7.1
