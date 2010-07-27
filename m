From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 1/7] bnx2x: Create separate folder for bnx2x
 driver
Date: Tue, 27 Jul 2010 22:04:38 +0300
Message-ID: <1280257478.8566.11.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4412 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858Ab0G0TQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 15:16:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit includes files movement to newly created folder
using git-mv command and fixes references in cnic and bnx2x code
to each other.

files moved using following:
#!/bin/bash
mkdir drivers/net/bnx2x/
list=$(cd drivers/net/ && ls bnx2x*.[ch])
for f in $list; do
        git mv -f drivers/net/$f drivers/net/bnx2x/$f
done

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/Makefile                        |    3 +--
 drivers/net/bnx2x/Makefile                  |    8 ++++++++
 drivers/net/{ => bnx2x}/bnx2x.h             |    2 +-
 drivers/net/{ => bnx2x}/bnx2x_dump.h        |    0
 drivers/net/{ => bnx2x}/bnx2x_fw_defs.h     |    0
 drivers/net/{ => bnx2x}/bnx2x_fw_file_hdr.h |    0
 drivers/net/{ => bnx2x}/bnx2x_hsi.h         |    0
 drivers/net/{ => bnx2x}/bnx2x_init.h        |    0
 drivers/net/{ => bnx2x}/bnx2x_init_ops.h    |    0
 drivers/net/{ => bnx2x}/bnx2x_link.c        |    0
 drivers/net/{ => bnx2x}/bnx2x_link.h        |    0
 drivers/net/{ => bnx2x}/bnx2x_main.c        |    0
 drivers/net/{ => bnx2x}/bnx2x_reg.h         |    0
 drivers/net/cnic.c                          |    6 +++---
 14 files changed, 13 insertions(+), 6 deletions(-)
 create mode 100644 drivers/net/bnx2x/Makefile
 rename drivers/net/{ => bnx2x}/bnx2x.h (99%)
 rename drivers/net/{ => bnx2x}/bnx2x_dump.h (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_fw_defs.h (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_fw_file_hdr.h (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_hsi.h (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_init.h (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_init_ops.h (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_link.c (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_link.h (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_main.c (100%)
 rename drivers/net/{ => bnx2x}/bnx2x_reg.h (100%)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ce55581..56e8c27 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -84,8 +84,7 @@ obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_TIGON3) += tg3.o
 obj-$(CONFIG_BNX2) += bnx2.o
 obj-$(CONFIG_CNIC) += cnic.o
-obj-$(CONFIG_BNX2X) += bnx2x.o
-bnx2x-objs := bnx2x_main.o bnx2x_link.o
+obj-$(CONFIG_BNX2X) += bnx2x/
 spidernet-y += spider_net.o spider_net_ethtool.o
 obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
diff --git a/drivers/net/bnx2x/Makefile b/drivers/net/bnx2x/Makefile
new file mode 100644
index 0000000..797907f
--- /dev/null
+++ b/drivers/net/bnx2x/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for Broadcom 10-Gigabit ethernet driver
+#
+
+obj-$(CONFIG_BNX2X) += bnx2x.o
+
+bnx2x-objs := bnx2x_main.o bnx2x_link.o
+
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
similarity index 99%
rename from drivers/net/bnx2x.h
rename to drivers/net/bnx2x/bnx2x.h
index 8bd2368..3b51c5f 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -32,7 +32,7 @@
 
 #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
 #define BCM_CNIC 1
-#include "cnic_if.h"
+#include "../cnic_if.h"
 #endif
 
 
diff --git a/drivers/net/bnx2x_dump.h b/drivers/net/bnx2x/bnx2x_dump.h
similarity index 100%
rename from drivers/net/bnx2x_dump.h
rename to drivers/net/bnx2x/bnx2x_dump.h
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x/bnx2x_fw_defs.h
similarity index 100%
rename from drivers/net/bnx2x_fw_defs.h
rename to drivers/net/bnx2x/bnx2x_fw_defs.h
diff --git a/drivers/net/bnx2x_fw_file_hdr.h b/drivers/net/bnx2x/bnx2x_fw_file_hdr.h
similarity index 100%
rename from drivers/net/bnx2x_fw_file_hdr.h
rename to drivers/net/bnx2x/bnx2x_fw_file_hdr.h
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
similarity index 100%
rename from drivers/net/bnx2x_hsi.h
rename to drivers/net/bnx2x/bnx2x_hsi.h
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x/bnx2x_init.h
similarity index 100%
rename from drivers/net/bnx2x_init.h
rename to drivers/net/bnx2x/bnx2x_init.h
diff --git a/drivers/net/bnx2x_init_ops.h b/drivers/net/bnx2x/bnx2x_init_ops.h
similarity index 100%
rename from drivers/net/bnx2x_init_ops.h
rename to drivers/net/bnx2x/bnx2x_init_ops.h
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
similarity index 100%
rename from drivers/net/bnx2x_link.c
rename to drivers/net/bnx2x/bnx2x_link.c
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
similarity index 100%
rename from drivers/net/bnx2x_link.h
rename to drivers/net/bnx2x/bnx2x_link.h
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
similarity index 100%
rename from drivers/net/bnx2x_main.c
rename to drivers/net/bnx2x/bnx2x_main.c
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
similarity index 100%
rename from drivers/net/bnx2x_reg.h
rename to drivers/net/bnx2x/bnx2x_reg.h
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 5ecf0bc..0961032 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -40,9 +40,9 @@
 
 #include "cnic_if.h"
 #include "bnx2.h"
-#include "bnx2x_reg.h"
-#include "bnx2x_fw_defs.h"
-#include "bnx2x_hsi.h"
+#include "bnx2x/bnx2x_reg.h"
+#include "bnx2x/bnx2x_fw_defs.h"
+#include "bnx2x/bnx2x_hsi.h"
 #include "../scsi/bnx2i/57xx_iscsi_constants.h"
 #include "../scsi/bnx2i/57xx_iscsi_hsi.h"
 #include "cnic.h"
-- 
1.7.1




