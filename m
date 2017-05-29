From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 10/17] net: qualcomm: rename qca_framing.c to qca_7k_common.c
Date: Mon, 29 May 2017 13:57:18 +0200
Message-ID: <1496059045-13572-11-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As preparation for the upcoming UART driver we need a module
which contains common functions for both interfaces. The module
qca_framing is a good candidate but renaming to qca_7k_common would
make it clear.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/Makefile                           | 2 +-
 drivers/net/ethernet/qualcomm/{qca_framing.c => qca_7k_common.c} | 2 +-
 drivers/net/ethernet/qualcomm/{qca_framing.h => qca_7k_common.h} | 0
 drivers/net/ethernet/qualcomm/qca_spi.c                          | 2 +-
 drivers/net/ethernet/qualcomm/qca_spi.h                          | 2 +-
 5 files changed, 4 insertions(+), 4 deletions(-)
 rename drivers/net/ethernet/qualcomm/{qca_framing.c => qca_7k_common.c} (99%)
 rename drivers/net/ethernet/qualcomm/{qca_framing.h => qca_7k_common.h} (100%)

diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
index aacb0a5..5e17bf1 100644
--- a/drivers/net/ethernet/qualcomm/Makefile
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -3,6 +3,6 @@
 #
 
 obj-$(CONFIG_QCA7000) += qcaspi.o
-qcaspi-objs := qca_spi.o qca_framing.o qca_7k.o qca_debug.o
+qcaspi-objs := qca_spi.o qca_7k_common.o qca_7k.o qca_debug.o
 
 obj-y += emac/
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.c b/drivers/net/ethernet/qualcomm/qca_7k_common.c
similarity index 99%
rename from drivers/net/ethernet/qualcomm/qca_framing.c
rename to drivers/net/ethernet/qualcomm/qca_7k_common.c
index 2341f2b..6d17fbd 100644
--- a/drivers/net/ethernet/qualcomm/qca_framing.c
+++ b/drivers/net/ethernet/qualcomm/qca_7k_common.c
@@ -23,7 +23,7 @@
 
 #include <linux/kernel.h>
 
-#include "qca_framing.h"
+#include "qca_7k_common.h"
 
 u16
 qcafrm_create_header(u8 *buf, u16 length)
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.h b/drivers/net/ethernet/qualcomm/qca_7k_common.h
similarity index 100%
rename from drivers/net/ethernet/qualcomm/qca_framing.h
rename to drivers/net/ethernet/qualcomm/qca_7k_common.h
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index ee90af3..43cc7de 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -43,8 +43,8 @@
 #include <linux/types.h>
 
 #include "qca_7k.h"
+#include "qca_7k_common.h"
 #include "qca_debug.h"
-#include "qca_framing.h"
 #include "qca_spi.h"
 
 #define MAX_DMA_BURST_LEN 5000
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.h b/drivers/net/ethernet/qualcomm/qca_spi.h
index 064853d..fc4beb1 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.h
+++ b/drivers/net/ethernet/qualcomm/qca_spi.h
@@ -32,7 +32,7 @@
 #include <linux/spi/spi.h>
 #include <linux/types.h>
 
-#include "qca_framing.h"
+#include "qca_7k_common.h"
 
 #define QCASPI_DRV_VERSION "0.2.7-i"
 #define QCASPI_DRV_NAME    "qcaspi"
-- 
2.1.4
