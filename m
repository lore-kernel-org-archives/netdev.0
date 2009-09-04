From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 01/29] ioat: move to drivers/dma/ioat/
Date: Thu, 03 Sep 2009 19:30:35 -0700
Message-ID: <20090904023035.32667.87323.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932561AbZIDCah@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When first created the ioat driver was the only inhabitant of
drivers/dma/.  Now, it is the only multi-file (more than a .c and a .h)
driver in the directory.  Moving it to an ioat/ subdirectory allows the
naming convention to be cleaned up, and allows for future splitting of
the source files by hardware version (v1, v2, and v3).

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/Makefile            |    3 +--
 drivers/dma/ioat/Makefile       |    2 ++
 drivers/dma/ioat/dca.c          |    4 ++--
 drivers/dma/ioat/dma.c          |    6 +++---
 drivers/dma/ioat/dma.h          |    2 +-
 drivers/dma/ioat/hw.h           |    0 
 drivers/dma/ioat/pci.c          |    6 +++---
 drivers/dma/ioat/registers.h    |    0 
 8 files changed, 12 insertions(+), 11 deletions(-)
 create mode 100644 drivers/dma/ioat/Makefile
 rename drivers/dma/{ioat_dca.c => ioat/dca.c} (99%)
 rename drivers/dma/{ioat_dma.c => ioat/dma.c} (99%)
 rename drivers/dma/{ioatdma.h => ioat/dma.h} (99%)
 rename drivers/dma/{ioatdma_hw.h => ioat/hw.h} (100%)
 rename drivers/dma/{ioat.c => ioat/pci.c} (98%)
 rename drivers/dma/{ioatdma_registers.h => ioat/registers.h} (100%)

diff --git a/drivers/dma/Makefile b/drivers/dma/Makefile
index 2e5dc96..a1cb285 100644
--- a/drivers/dma/Makefile
+++ b/drivers/dma/Makefile
@@ -1,8 +1,7 @@
 obj-$(CONFIG_DMA_ENGINE) += dmaengine.o
 obj-$(CONFIG_NET_DMA) += iovlock.o
 obj-$(CONFIG_DMATEST) += dmatest.o
-obj-$(CONFIG_INTEL_IOATDMA) += ioatdma.o
-ioatdma-objs := ioat.o ioat_dma.o ioat_dca.o
+obj-$(CONFIG_INTEL_IOATDMA) += ioat/
 obj-$(CONFIG_INTEL_IOP_ADMA) += iop-adma.o
 obj-$(CONFIG_FSL_DMA) += fsldma.o
 obj-$(CONFIG_MV_XOR) += mv_xor.o
diff --git a/drivers/dma/ioat/Makefile b/drivers/dma/ioat/Makefile
new file mode 100644
index 0000000..2ce3d3a
--- /dev/null
+++ b/drivers/dma/ioat/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_INTEL_IOATDMA) += ioatdma.o
+ioatdma-objs := pci.o dma.o dca.o
diff --git a/drivers/dma/ioat_dca.c b/drivers/dma/ioat/dca.c
similarity index 99%
rename from drivers/dma/ioat_dca.c
rename to drivers/dma/ioat/dca.c
index c012a1e..af1c762 100644
--- a/drivers/dma/ioat_dca.c
+++ b/drivers/dma/ioat/dca.c
@@ -33,8 +33,8 @@
 #define cpu_physical_id(cpu) (cpuid_ebx(1) >> 24)
 #endif
 
-#include "ioatdma.h"
-#include "ioatdma_registers.h"
+#include "dma.h"
+#include "registers.h"
 
 /*
  * Bit 7 of a tag map entry is the "valid" bit, if it is set then bits 0:6
diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat/dma.c
similarity index 99%
rename from drivers/dma/ioat_dma.c
rename to drivers/dma/ioat/dma.c
index a600fc0..648797e 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -34,9 +34,9 @@
 #include <linux/dma-mapping.h>
 #include <linux/workqueue.h>
 #include <linux/i7300_idle.h>
-#include "ioatdma.h"
-#include "ioatdma_registers.h"
-#include "ioatdma_hw.h"
+#include "dma.h"
+#include "registers.h"
+#include "hw.h"
 
 #define to_ioat_chan(chan) container_of(chan, struct ioat_dma_chan, common)
 #define to_ioatdma_device(dev) container_of(dev, struct ioatdma_device, common)
diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioat/dma.h
similarity index 99%
rename from drivers/dma/ioatdma.h
rename to drivers/dma/ioat/dma.h
index a52ff4b..e80e787 100644
--- a/drivers/dma/ioatdma.h
+++ b/drivers/dma/ioat/dma.h
@@ -22,7 +22,7 @@
 #define IOATDMA_H
 
 #include <linux/dmaengine.h>
-#include "ioatdma_hw.h"
+#include "hw.h"
 #include <linux/init.h>
 #include <linux/dmapool.h>
 #include <linux/cache.h>
diff --git a/drivers/dma/ioatdma_hw.h b/drivers/dma/ioat/hw.h
similarity index 100%
rename from drivers/dma/ioatdma_hw.h
rename to drivers/dma/ioat/hw.h
diff --git a/drivers/dma/ioat.c b/drivers/dma/ioat/pci.c
similarity index 98%
rename from drivers/dma/ioat.c
rename to drivers/dma/ioat/pci.c
index 2225bb6..d7948bf 100644
--- a/drivers/dma/ioat.c
+++ b/drivers/dma/ioat/pci.c
@@ -30,9 +30,9 @@
 #include <linux/pci.h>
 #include <linux/interrupt.h>
 #include <linux/dca.h>
-#include "ioatdma.h"
-#include "ioatdma_registers.h"
-#include "ioatdma_hw.h"
+#include "dma.h"
+#include "registers.h"
+#include "hw.h"
 
 MODULE_VERSION(IOAT_DMA_VERSION);
 MODULE_LICENSE("GPL");
diff --git a/drivers/dma/ioatdma_registers.h b/drivers/dma/ioat/registers.h
similarity index 100%
rename from drivers/dma/ioatdma_registers.h
rename to drivers/dma/ioat/registers.h
